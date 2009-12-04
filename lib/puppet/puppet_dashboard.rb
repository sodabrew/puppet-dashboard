require 'puppet'

HOST = 'localhost'
PORT = 3000

Puppet::Reports.register_report(:puppet_dashboard) do
  desc "Send report information to Puppet-Dashboard"

  def process
    Net::HTTP.start(HOST, PORT) do |conn|
      conn.post "/reports", "report=" + CGI.escape(self.to_yaml)
    end
  end
end
