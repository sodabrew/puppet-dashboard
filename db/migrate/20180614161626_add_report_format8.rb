class AddReportFormat8 < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :transaction_completed, :boolean
  end
end
