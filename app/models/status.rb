class Status
  attr_reader :failed, :total, :percent, :start
  def initialize(datum)
    @failed   = datum["failed"].to_i
    @total    = datum["total"].to_i
    @percent  = datum["percent"].to_f
    @start    = datum["start"].to_time
  end
 
  def self.latest(options={})
    by_interval(options.merge(:limit => 1)).first
  end

  def self.recent(options={})
    by_interval options.merge(:start => 30.minutes.ago)
  end

  def self.sparkline
    # return [12.5, 10.5, 13.4, 11.4, 13.2, 12.3, 13.4, 14.3]
    by_interval.map(&:percent)
  end

  def self.by_interval(options={})
    interval = options[:of] || 5.minutes

    sql = <<-SQL
      SELECT
        COUNT(*) - SUM(success) as failed,
        COUNT(*) as total,
        (COUNT(*) - SUM(success)) / COUNT(*) as percent,
        FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(created_at) / #{interval}) * #{interval}) as start
      FROM reports
    SQL

    sql << %{ WHERE created_at >= "#{options[:start].to_s(:db)}"} if options[:start]
    sql << " GROUP BY FLOOR(UNIX_TIMESTAMP(created_at) / #{interval})"

    sql << " LIMIT #{options[:limit]}" if options[:limit]

    execute sql
  end

  private

  def self.execute(sql)
    ActiveRecord::Base.connection.execute(sql).all_hashes.map{|datum| new datum}
  end
end
