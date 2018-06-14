class AddReportFormat9 < ActiveRecord::Migration[5.2]
  def change
    add_column :resource_statuses, :provider_used, :string
  end
end
