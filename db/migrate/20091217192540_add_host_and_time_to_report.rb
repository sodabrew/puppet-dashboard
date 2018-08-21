class AddHostAndTimeToReport < ActiveRecord::Migration[4.2]
  def self.up
    add_column :reports, :host, :string
    add_column :reports, :time, :datetime
  end

  def self.down
    remove_column :reports, :time
    remove_column :reports, :host
  end
end
