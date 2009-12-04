require 'puppet'

Puppet::Reports.register_report(:puppet_dashboard) do
  desc "Send report information to Puppet-Dashboard"

  def process
    Net::HTTP.start('localhost', 3000) do |conn|
      conn.post "/reports", "report=" + CGI.escape(self.to_yaml)
    end
  end
end
