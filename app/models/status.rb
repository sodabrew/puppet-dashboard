class Status
  attr_reader :failed, :total, :percent, :start
  def initialize(datum)
    @failed = datum["failed"].to_i
    @total = datum["total"].to_i
    @percent = datum["percent"].to_f
    @start = datum["start"].to_time
  end
 
  def self.latest(options={})
    by_interval(options.merge(:limit => 1)).first
  end

  def self.recent(options={})
    by_interval options.merge(:start => 1.hour.ago)
  end

  def self.sparkline
    # return [12.5, 10.5, 13.4, 11.4, 13.2, 12.3, 13.4, 14.3]
    by_interval(:limit => 20).map(&:percent)
  end

  def self.by_interval(options={})
    return [] if options[:nodes] && options[:nodes].empty?
    interval = options[:of] || 1.day

    has_where = options[:start] || options[:node] || options[:nodes].present?

    has_and = options[:start]
    has_and &&= options[:node] or options[:nodes].present?

    sql = <<-SQL

    SELECT
      COUNT(*) - SUM(success)       as failed,
      COUNT(*)                      as total,
      SUM(success) / COUNT(*) * 100 as percent,
      FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(time) / #{interval}) * #{interval}) as start
    FROM reports
    SQL

    sql << "WHERE " if has_where
    sql << "time >= \"#{options[:start].to_s(:db)}\"}\n" if options[:start]
    sql << "AND " if has_and
    sql << "node_id = #{options[:node].id} " if options[:node]
    sql << "node_id IN (#{options[:nodes].map(&:id).join(',')})\n" if options[:nodes].present?
    sql << "GROUP BY FLOOR(UNIX_TIMESTAMP(time) / #{interval})\n"
    sql << "ORDER BY time DESC\n"
    sql << "LIMIT #{options[:limit]}" if options[:limit]

    execute(sql).reverse
  end

  def self.runtime
    Report.all(:limit => 20, :order => 'time DESC').map{|r| r.metrics[:time][:total]}
  end

  private

  def self.execute(sql)
    ActiveRecord::Base.connection.execute(sql).all_hashes.map{|datum| new datum}
  end
end
