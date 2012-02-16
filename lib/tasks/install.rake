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

  desc "Submit a certificate request to the Puppet Master"
  task :request => :environment do
    require 'openssl'
    require 'puppet_https'
    require 'cgi'
    key = OpenSSL::PKey::RSA.new(File.read(SETTINGS.private_key_path))

    cert_req = OpenSSL::X509::Request.new
    cert_req.version = 0
    cert_req.subject = OpenSSL::X509::Name.new([["CN", SETTINGS.cn_name]])
    cert_req.public_key = key.public_key
    cert_req.sign(key, OpenSSL::Digest::MD5.new)

    begin
      PuppetHttps.put("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate_request/#{CGI::escape(SETTINGS.cn_name)}",
                      'text/plain', cert_req.to_s, false)
    rescue SocketError => e
      raise SocketError, "Unable to contact CA server #{SETTINGS.ca_server}: #{e.message}"
    end
  end

  desc "Retrieve a certificate from the Puppet Master"
  task :retrieve => :environment do
    require 'openssl'
    require 'puppet_https'
    require 'cgi'
    begin
      cert_s = PuppetHttps.get("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate/#{CGI::escape(SETTINGS.cn_name)}", 's', false)
      cert = OpenSSL::X509::Certificate.new(cert_s)
      key = OpenSSL::PKey::RSA.new(File.read(SETTINGS.public_key_path))
      raise "Certificate doesn't match key" unless cert.public_key.to_s == key.to_s
      FileUtils.mkdir_p(File.dirname(SETTINGS.certificate_path))
      File.open(SETTINGS.certificate_path, 'w') do |file|
        file.print cert_s
      end

      ca_cert_s = PuppetHttps.get("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate/ca", 's', false)
      ca_cert = OpenSSL::X509::Certificate.new(ca_cert_s)
      raise "Certificate isn't signed by CA" unless cert.verify(ca_cert.public_key)
      File.open(SETTINGS.ca_certificate_path, 'w') do |file|
        file.print ca_cert_s
      end

      ca_crl_s = PuppetHttps.get("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate_revocation_list/ca", 's')
      File.open(SETTINGS.ca_crl_path, 'w') do |file|
        file.print ca_crl_s
      end
    rescue SocketError => e
      raise SocketError, "Unable to contact CA server #{SETTINGS.ca_server}: #{e.message}"
    end
  end
end
