class AddTransactionUuidToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :transaction_uuid, :string
  end
end
