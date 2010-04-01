class Report
  generator_for :host, :start => 'host.name.aaaa'

  def report
    Struct.new(:time, :metrics, :host).new(Time.now, {}, self.host)
  end
end
