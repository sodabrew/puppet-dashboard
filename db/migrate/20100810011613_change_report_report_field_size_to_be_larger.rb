class ChangeReportReportFieldSizeToBeLarger < ActiveRecord::Migration[4.2]
  @postgres = ActiveRecord::Base.connection.adapter_name.downcase =~ /postgres/

  def self.up
    # data type 'text' is unlimited in postgres
    unless @postgres
      count = Report.where(['length(reports.report) = ?', 65535]).delete_all
      if count > 0
        say "WARNING: Deleted #{count} invalid reports that were truncated by the database due to an earlier bug. Please import your reports again (see README for details) if you wish to have these deleted reports re-added to your database correctly."
      end

      say "Increasing column size of reports to avoid truncation problems:"
      change_column( :reports, :report, :mediumtext, :limit => 16.megabytes )
    end
  end

  def self.down
    unless @postgres
      change_column( :reports, :report, :text )
    end
  end
end
