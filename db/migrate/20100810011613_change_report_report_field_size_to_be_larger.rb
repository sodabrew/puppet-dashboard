class ChangeReportReportFieldSizeToBeLarger < ActiveRecord::Migration
  def self.up
    #First delete truncated reports that cause errors
    Report.destroy_all(['length(reports.report) = ?', 65535])

    # Next change the report column to a longer length that should handle pretty much any sane report
    change_column( :reports, :report, :mediumtext, :limit => 16.megabytes )
  end

  def self.down
    change_column( :reports, :report, :text )
  end
end
