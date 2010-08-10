class ChangeReportReportFieldSizeToBeLarger < ActiveRecord::Migration
  def self.up
    change_column( :reports, :report, :mediumtext, :limit => 16.megabytes )
  end

  def self.down
    change_column( :reports, :report, :text )
  end
end
