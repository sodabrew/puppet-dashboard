class AddReportFormat6 < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :noop,              :boolean
    add_column :reports, :noop_pending,      :boolean
    add_column :reports, :corrective_change, :boolean
    add_column :reports, :master_used,       :string

    add_column :resource_statuses, :corrective_change, :boolean

    add_column :resource_events, :corrective_change, :boolean
    add_column :resource_events, :redacted,          :boolean
  end
end
