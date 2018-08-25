class AddCatalogUuidToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :catalog_uuid, :string
  end
end
