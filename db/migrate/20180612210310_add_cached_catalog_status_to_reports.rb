class AddCachedCatalogStatusToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :cached_catalog_status, :string
  end
end
