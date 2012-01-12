class RemoveUrlFromNodes < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :url
  end

  def self.down
    add_column :nodes, :url, :string
  end
end
