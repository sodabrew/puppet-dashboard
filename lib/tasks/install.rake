desc "Install the Puppet Dashboard"
task :install do
  puts "Please see the README.markdown file for installation instructions."
end

desc "Update the Puppet Dashboard"
task :update => ['db:migrate']

desc "Create a public/private key pair for communication with the Puppet Master"
task :create_key_pair => :environment do
  require 'openssl'
  require 'puppet_https'

  if File.exists?(PuppetHttps.private_key_path) or File.exists?(PuppetHttps.public_key_path)
    raise "Key(s) already exist."
  end

  key = OpenSSL::PKey::RSA.new(SETTINGS.key_length)

  FileUtils.mkdir_p(File.dirname(PuppetHttps.private_key_path))
  old_umask = File.umask(0226) # user read and group read only
  begin
    File.open(PuppetHttps.private_key_path, 'w') do |file|
      file.print key
    end
  ensure
    File.umask(old_umask)
  end
  FileUtils.mkdir_p(File.dirname(PuppetHttps.public_key_path))
  File.open(PuppetHttps.public_key_path, 'w') do |file|
    file.print key.public_key
  end
end

desc "Submit a certificate request to the Puppet Master"
task :cert_request => :environment do
  require 'openssl'
  require 'puppet_https'
  require 'cgi'
  key = OpenSSL::PKey::RSA.new(File.read(PuppetHttps.private_key_path))

  cert_req = OpenSSL::X509::Request.new
  cert_req.version = 0
  cert_req.subject = OpenSSL::X509::Name.new([["CN", SETTINGS.cn_name]])
  cert_req.public_key = key.public_key
  cert_req.sign(key, OpenSSL::Digest::MD5.new)

  PuppetHttps.put("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate_request/#{CGI::escape(SETTINGS.cn_name)}",
                  'text/plain', cert_req.to_s, false)
end

desc "Retrieve a certificate from the Puppet Master"
task :cert_retrieve => :environment do
  require 'openssl'
  require 'puppet_https'
  require 'cgi'
  cert_s = PuppetHttps.get("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate/#{CGI::escape(SETTINGS.cn_name)}", 's', false)
  cert = OpenSSL::X509::Certificate.new(cert_s)
  key = OpenSSL::PKey::RSA.new(File.read(PuppetHttps.public_key_path))
  raise "Certificate doesn't match key" unless cert.public_key.to_s == key.to_s
  FileUtils.mkdir_p(File.dirname(PuppetHttps.certificate_path))
  File.open(PuppetHttps.certificate_path, 'w') do |file|
    file.print cert_s
  end

  ca_cert_s = PuppetHttps.get("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate/ca", 's', false)
  ca_cert = OpenSSL::X509::Certificate.new(ca_cert_s)
  raise "Certificate isn't signed by CA" unless cert.verify(ca_cert.public_key)
  File.open(PuppetHttps.ca_certificate_path, 'w') do |file|
    file.print ca_cert_s
  end

  ca_crl_s = PuppetHttps.get("https://#{SETTINGS.ca_server}:#{SETTINGS.ca_port}/production/certificate_revocation_list/ca", 's')
  File.open(PuppetHttps.ca_crl_path, 'w') do |file|
    file.print ca_crl_s
  end
end
