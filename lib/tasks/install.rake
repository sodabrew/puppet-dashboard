desc "Install the Puppet Dashboard"
task :install do
  puts "Please see the README.markdown file for installation instructions."
end

desc "Update the Puppet Dashboard"
task :update => ['db:migrate']

namespace :cert do
  desc "Create a public/private key pair for communication with the Puppet Master"
  task :create_key_pair => :environment do
    require 'openssl'
    require 'puppet_https'

    if File.exists?(SETTINGS.private_key_path) or File.exists?(SETTINGS.public_key_path)
      raise "Key(s) already exist."
    end

    key = OpenSSL::PKey::RSA.new(SETTINGS.key_length)

    FileUtils.mkdir_p(File.dirname(SETTINGS.private_key_path))
    old_umask = File.umask(0226) # user read and group read only
    begin
      File.open(SETTINGS.private_key_path, 'w') do |file|
        file.print key
      end
    ensure
      File.umask(old_umask)
    end
    FileUtils.mkdir_p(File.dirname(SETTINGS.public_key_path))
    File.open(SETTINGS.public_key_path, 'w') do |file|
      file.print key.public_key
    end
  end

  # Test server for Cert API v1 compatibility
  def get_cert_api( settings )
    cert_api = {
      :server => "https://#{settings.ca_server}:#{settings.ca_port}",
      :prefix => '/puppet-ca/v1',
      :options => 'environment=production&',
    }

    print "Testing CA server for Certificate API v1 compatibility..." if verbose == true
    begin
      result = PuppetHttps.get("#{cert_api[:server]}#{cert_api[:prefix]}/certificate/ca?#{cert_api[:options]}", 's', false)
    rescue Net::HTTPServerException => e
      # 404s might indicate a pre-v1 API
      if e.response.code != '404'
        raise "Unable to request CA certificate from CA server #{settings.ca_server}: #{e.message}"
      end
    rescue SocketError => e
      raise SocketError, "Unable to contact CA server #{settings.ca_server}: #{e.message}"
    end

    # Try pre-v1 API
    if result.nil?
      print "failed.\nTesting CA server for pre-v1 API compatibility..." if verbose == true
      begin
        v3result = PuppetHttps.get("#{cert_api[:server]}/production/certificate/ca", 's', false)
      rescue Net::HTTPServerException => e
        raise "Unable to request CA certificate from CA server #{settings.ca_server}: #{e.message}"
      rescue SocketError => e
        raise SocketError, "Unable to contact CA server #{settings.ca_server}: #{e.message}"
      end

      if !v3result.nil?
        print "succeeded.\nPuppet master pre-v4 detected.\n" if verbose == true
        # reset to original pre-v1 paths
        cert_api[:prefix] = '/production'
        cert_api[:options] = ''
      else
        cert_api[:ca_certificate] = v3result
      end
    else
      print "succeeded.\nPuppet Certificate API v1 verified.\n" if verbose == true
      cert_api[:ca_certificate] = result
    end

    return cert_api
  end

  desc "Submit a certificate request to the Puppet Master"
  task :request => :environment do
    require 'openssl'
    require 'puppet_https'
    require 'cgi'
    cert_api = get_cert_api( SETTINGS )
    key = OpenSSL::PKey::RSA.new(File.read(SETTINGS.private_key_path))

    certname = CGI::escape(SETTINGS.cn_name)
    cert_req = OpenSSL::X509::Request.new
    cert_req.version = 0
    cert_req.subject = OpenSSL::X509::Name.new([["CN", SETTINGS.cn_name]])
    cert_req.public_key = key.public_key
    cert_req.sign(key, OpenSSL::Digest::SHA256.new)

    print "Submitting certificate request to CA server..." if verbose == true
    begin
      PuppetHttps.put("#{cert_api[:server]}#{cert_api[:prefix]}/certificate_request/#{certname}?#{cert_api[:options]}",
                      'text/plain', cert_req.to_s, false)

    rescue Net::HTTPServerException => e
      raise "Unable to submit certificate request to the CA server #{SETTINGS.ca_server}: #{e.message}"

    rescue SocketError => e
      raise SocketError, "Unable to contact CA server #{SETTINGS.ca_server}: #{e.message}"
    end
    print "sent.\n"
  end

  desc "Retrieve a certificate from the Puppet Master"
  task :retrieve => :environment do
    require 'openssl'
    require 'puppet_https'
    require 'cgi'

    # Test Puppet API v1 first by grabbing CA certificate
    cert_api = get_cert_api( SETTINGS )
    certname = CGI::escape(SETTINGS.cn_name)

    begin
      print "Requesting the signed certificate from the CA server..." if verbose == true
      cert_s = PuppetHttps.get("#{cert_api[:server]}#{cert_api[:prefix]}/certificate/#{certname}?#{cert_api[:options]}", 's', false)
      print "got it.\n" if verbose == true
      cert = OpenSSL::X509::Certificate.new(cert_s)
      key = OpenSSL::PKey::RSA.new(File.read(SETTINGS.public_key_path))
      raise "Certificate doesn't match key" unless cert.public_key.to_s == key.to_s
      FileUtils.mkdir_p(File.dirname(SETTINGS.certificate_path))
      File.open(SETTINGS.certificate_path, 'w') do |file|
        file.print cert_s
      end

      # Store the CA certificate
      ca_cert = OpenSSL::X509::Certificate.new(cert_api[:ca_certificate])
      raise "Certificate isn't signed by CA" unless cert.verify(ca_cert.public_key)
      File.open(SETTINGS.ca_certificate_path, 'w') do |file|
        file.print cert_api[:ca_certificate]
      end

      # Store the CA's CRL 
      print "Requesting the CA's revocation list..." if verbose == true
      ca_crl_s = PuppetHttps.get("#{cert_api[:server]}#{cert_api[:prefix]}/certificate_revocation_list/ca?#{cert_api[:options]}", 's')
      File.open(SETTINGS.ca_crl_path, 'w') do |file|
        file.print ca_crl_s
      end
      print "got it.\n" if verbose == true

    rescue Net::HTTPServerException => e
      # 404s might indicate certificate hasn't been signed yet
      if e.response.code == '404'
        print "Certificate not found. Certificate may not yet be signed on #{SETTINGS.ca_server}.\n"
      else
        raise "Unable to retrieve certificate from CA server #{SETTINGS.ca_server}: #{e.message}"
      end

    rescue SocketError => e
      raise SocketError, "Unable to contact CA server #{SETTINGS.ca_server}: #{e.message}"
    end
  end
end
