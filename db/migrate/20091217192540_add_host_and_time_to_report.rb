class AddHostAndTimeToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :host, :string
    add_column :reports, :time, :datetime
  end

  def self.down
    remove_column :reports, :time
    remove_column :reports, :host
  end
end
