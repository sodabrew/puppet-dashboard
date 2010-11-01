require 'uri'
require 'net/https'

class PuppetHttps
  def self.certificate_path
    SETTINGS.certificate_path
  end

  def self.private_key_path
    SETTINGS.private_key_path
  end

  def self.public_key_path
    SETTINGS.public_key_path
  end

  def self.make_ssl_request(url, req)
    connection = Net::HTTP.new(url.host, url.port)
    connection.use_ssl = true
    if File.exists?(certificate_path)
      connection.cert = OpenSSL::X509::Certificate.new(File.read(certificate_path))
    end
    if File.exists?(private_key_path)
      connection.key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
    end
    connection.start { |http| http.request(req) }
  end

  def self.put(url, content_type, data)
    url = URI.parse(url)
    req = Net::HTTP::Put.new(url.path)
    req.content_type = content_type
    req.body = data
    res = make_ssl_request(url, req)
    res.error! unless res.code_type == Net::HTTPOK
  end

  def self.get(url, accept)
    url = URI.parse(url)
    req = Net::HTTP::Get.new(url.path, "Accept" => accept)
    res = make_ssl_request(url, req)
    res.body
  end
end
