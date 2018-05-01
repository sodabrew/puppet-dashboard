class AddUrlToNode < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :url, :string
  end

  def self.down
    remove_column :nodes, :url
  end
end
