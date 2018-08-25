class AddEnvironmentToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :environment, :string
  end
end
