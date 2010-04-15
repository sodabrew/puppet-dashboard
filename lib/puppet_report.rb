require 'puppet/transaction/report'
class Puppet::Transaction::Report
  def inspect
    "#<#{self.class}:0x#{object_id.to_s(16)}>"
  end
end
