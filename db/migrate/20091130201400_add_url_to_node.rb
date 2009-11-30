class AddUrlToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :url, :string
  end

  def self.down
    remove_column :nodes, :url
  end
end
