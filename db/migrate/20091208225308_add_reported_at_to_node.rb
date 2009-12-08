class AddReportedAtToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :reported_at, :timestamp
  end

  def self.down
    remove_column :nodes, :reported_at
  end
end
