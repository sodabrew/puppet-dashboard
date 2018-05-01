class AddEnvironmentToNodes < ActiveRecord::Migration[4.2]
  def change
    add_column :nodes, :environment, :string
  end
end
