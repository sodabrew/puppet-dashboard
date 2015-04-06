class AddEnvironmentToReports < ActiveRecord::Migration
  def change
    add_column :reports, :environment, :string
  end
end
