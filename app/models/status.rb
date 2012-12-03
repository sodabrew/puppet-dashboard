class Status
  attr_reader :changed, :unchanged, :pending, :failed, :total, :start
  def initialize(datum)
    @changed = datum["changed"].to_i
    @unchanged = datum["unchanged"].to_i
    @pending = datum["pending"].to_i
    @failed = datum["failed"].to_i
    @total = datum["total"].to_i
    @start = Time.zone.parse(datum["start"])
  end

  # Returns an array of Statuses by date for either a :node, or :nodes or all nodes in the system.
  #
  # Options:
  # * :node  => Node to return Statuses for.
  # * :nodes => Nodes to return Statuses for.
  def self.within_daily_run_history(options={})
    return [] if options[:nodes] && options[:nodes].empty?

    last_day = Time.zone.now + 1.day             # Last full day to include (ignores time).
    limit    = SETTINGS.daily_run_history_length # Limit the number of days to return (includes "last_day").

    utc_date_boundaries     = get_utc_boundaries_ending(last_day, limit + 1)
    newest_accepatable_data = utc_date_boundaries.first

    boundary_groupings = "CASE\n"
    utc_date_boundaries.each do |boundary|
      # We use the '%Y-%m-%d %H:%M:%S %z' strftime to get something parse-able
      # by Time.zone.parse and lexically sortable.
      boundary_groupings << "WHEN time >= '#{boundary.utc.to_s(:db)}' THEN '#{boundary.strftime("%Y-%m-%d %H:%M:%S %z")}'\n"
    end
    boundary_groupings << "ELSE null\n"
    boundary_groupings << "END"

    sql = <<-SQL
      SELECT
        COUNT(*)                                            as total,
        SUM(CASE status when "unchanged" then 1 else 0 end) as unchanged,
        SUM(CASE status when "changed" then 1 else 0 end)   as changed,
        SUM(CASE status when "pending" then 1 else 0 end)   as pending,
        SUM(CASE status when "failed" then 1 else 0 end)    as failed,
        #{boundary_groupings}                               as start
      FROM reports
    SQL

    sql << "WHERE kind = 'apply'\n"
    sql << "AND time < \"#{newest_accepatable_data.utc.to_s(:db)}\"\n"
    sql << "AND time >= \"#{utc_date_boundaries.last.utc.to_s(:db)}\"\n"
    sql << "AND node_id = #{options[:node].id}\n"                      if options[:node]
    sql << "AND node_id IN (#{options[:nodes].map(&:id).join(',')})\n" if options[:nodes].present?
    sql << "GROUP BY start\n"
    sql << "ORDER BY start ASC\n"
    sql << "LIMIT #{limit}\n"

    return execute(sql)
  end

  def self.get_utc_boundaries_ending(date, num_days)
    (0..(num_days-1)).collect do |offset|
      x = date - offset.days
      Time.zone.local(x.year, x.month, x.day, 0, 0, 0)
    end
  end

  def self.runtime
    Report.all(:limit => 20, :order => 'time DESC').map{|r| r.metrics[:time][:total]}
  end

  private

  def self.execute(sql)
    ActiveRecord::Base.connection.execute(sql).all_hashes.map{|datum| new datum}
  end
end
