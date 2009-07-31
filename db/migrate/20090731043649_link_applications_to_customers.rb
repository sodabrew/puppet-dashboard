class LinkApplicationsToCustomers < ActiveRecord::Migration
  def self.up
    add_column :apps, :customer_id, :integer
  end

  def self.down
    remove_column :apps, :customer_id
  end
end
