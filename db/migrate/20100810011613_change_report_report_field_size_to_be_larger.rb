class ChangeReportReportFieldSizeToBeLarger < ActiveRecord::Migration
  def self.up
    count = Report.delete_all(['length(reports.report) = ?', 65535])
    if count > 0
      say "WARNING: Deleted #{count} invalid reports that were truncated by the database due to an earlier bug. Please import your reports again (see README for details) if you wish to have these deleted reports re-added to your database correctly."
    end

    say "Increasing column size of reports to avoid truncation problems:"
    change_column( :reports, :report, :mediumtext, :limit => 16.megabytes )
  end

  def self.down
    change_column( :reports, :report, :text )
  end
end
