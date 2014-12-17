class AddEnvironmentToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :environment, :string
  end
end
