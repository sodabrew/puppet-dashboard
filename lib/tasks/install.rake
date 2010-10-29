desc "Install the Puppet Dashboard"
task :install do
  puts "Please see the README.markdown file for installation instructions."
end

desc "Update the Puppet Dashboard"
task :update => ['db:migrate']

node_name = 'dashboard' # TODO: should be configurable, perhaps default to hostname
ca_hostname = 'localhost' # TODO: should be configurable
ca_port = 8140 # TODO: should be configurable

desc "Create a public/private key pair for communication with the Puppet Master"
task :create_key_pair do
  require 'openssl'
  require 'puppet_https'
  key_length = 1024 # TODO should be configurable?

  if File.exists?(PuppetHttps.private_key_path) or File.exists?(PuppetHttps.public_key_path)
    raise "Key(s) already exist."
  end

  key = OpenSSL::PKey::RSA.new(key_length)

  File.open(PuppetHttps.private_key_path, 'w') do |file|
    file.print key
  end
  File.open(PuppetHttps.public_key_path, 'w') do |file|
    file.print key.public_key
  end
end

desc "Submit a certificate request to the Puppet Master"
task :cert_request do
  require 'openssl'
  require 'puppet_https'
  require 'cgi'
  key = OpenSSL::PKey::RSA.new(File.read(PuppetHttps.private_key_path))

  cert_req = OpenSSL::X509::Request.new
  cert_req.version = 0
  cert_req.subject = OpenSSL::X509::Name.new([["CN", node_name]])
  cert_req.public_key = key.public_key
  cert_req.sign(key, OpenSSL::Digest::MD5.new)

  PuppetHttps.put("https://#{ca_hostname}:#{ca_port}/production/certificate_request/#{CGI::escape(node_name)}",
                  'text/plain', cert_req.to_s)
end

desc "Retrieve a certificate from the Puppet Master"
task :cert_retrieve do
  require 'openssl'
  require 'puppet_https'
  require 'cgi'
  cert_s = PuppetHttps.get("https://#{ca_hostname}:#{ca_port}/production/certificate/#{CGI::escape(node_name)}", 's')
  cert = OpenSSL::X509::Certificate.new(cert_s)
  key = OpenSSL::PKey::RSA.new(File.read(PuppetHttps.public_key_path))
  raise "Certificate doesn't match key" unless cert.public_key.to_s == key.to_s
  File.open(PuppetHttps.certificate_path, 'w') do |file|
    file.print cert_s
  end
end
