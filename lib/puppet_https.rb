require 'uri'
require 'net/https'

class PuppetHttps
  def self.make_ssl_request(url, req, authenticate)
    connection = Net::HTTP.new(url.host, url.port)
    connection.use_ssl = true
    if authenticate
      certpath = File.join(Rails.root, SETTINGS.certificate_path)
      pkey_path = File.join(Rails.root, SETTINGS.private_key_path)
      if File.exists?(certpath)
        connection.cert = OpenSSL::X509::Certificate.new(File.read(certpath))
      end
      if File.exists?(pkey_path)
        connection.key = OpenSSL::PKey::RSA.new(File.read(pkey_path))
      end
    end
    connection.start { |http| http.request(req) }
  end

  def self.put(url, content_type, data, authenticate = true)
    url = URI.parse(url)
    req = Net::HTTP::Put.new(url.path)
    req.content_type = content_type
    req.body = data
    res = make_ssl_request(url, req, authenticate)
    res.error! unless res.code_type == Net::HTTPOK
  end

  def self.get(url, accept, authenticate = true)
    url = URI.parse(url)
    req = Net::HTTP::Get.new("#{url.path}?#{url.query}", "Accept" => accept)
    res = make_ssl_request(url, req, authenticate)
    res.error! unless res.code_type == Net::HTTPOK
    res.body
  end
end
