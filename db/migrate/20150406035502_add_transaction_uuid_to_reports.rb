class AddTransactionUuidToReports < ActiveRecord::Migration
  def change
    add_column :reports, :transaction_uuid, :string
  end
end
