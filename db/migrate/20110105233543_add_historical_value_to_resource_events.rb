class AddHistoricalValueToResourceEvents < ActiveRecord::Migration[4.2]
  def self.up
    add_column :resource_events, :historical_value, :string
  end

  def self.down
    remove_column :resource_events, :historical_value
  end
end
