class AddStatusColumnToResourceStatuses < ActiveRecord::Migration
  def self.up
    add_column :resource_statuses, :status, :string

    # only going to update last report for each node since that's what people will care most about for counts
    # if users want all reports updated they can run the rake task
    Node.all.each do |n|
      last_report = n.last_apply_report
      next unless last_report
      last_report.munge
      last_report.save!
    end
  end

  def self.down
    remove_column :resource_statuses, :status
  end
end
