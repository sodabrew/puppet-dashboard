# Node view widgets
Registry.add_callback :core, :node_view_widgets, "100_description" do |view_renderer, node|
  view_renderer.render 'nodes/description', :node => node
end

Registry.add_callback :core, :node_view_widgets, "200_parameters" do |view_renderer, node|
  if SETTINGS.use_external_node_classification
    view_renderer.render 'shared/parameters', :resource => node
  end
end

Registry.add_callback :core, :node_view_widgets, "210_groups" do |view_renderer, node|
  view_renderer.render 'shared/groups', :resource => node
end

Registry.add_callback :core, :node_view_widgets, "220_classes" do |view_renderer, node|
  if SETTINGS.use_external_node_classification
    view_renderer.render 'shared/classes', :resource => node
  end
end

Registry.add_callback :core, :node_view_widgets, "400_reports" do |view_renderer, node|
  view_renderer.render 'nodes/reports', :node => node
end

Registry.add_callback :core, :node_view_widgets, "600_inspections" do |view_renderer, node|
  view_renderer.render 'nodes/inspections', :node => node
end

Registry.add_callback :core, :node_view_widgets, "650_inventory_service" do |view_renderer, node|
  view_renderer.render 'nodes/inventory_service', :node => node
end

Registry.add_callback :core, :node_view_widgets, "700_activity" do |view_renderer, node|
  view_renderer.render 'nodes/activity', :node => node
end

# Report view widgets
Registry.add_callback :core, :report_view_widgets, "800_resource_statuses" do |view_renderer, report|
  statuses = report.resource_statuses.all(:order => 'resource_type, title').group_by(&:status)
  statuses = %w[failed pending changed unchanged].map { |k| (v = statuses[k]) && [k, v] }
  view_renderer.render 'reports/resource_statuses', :report => report, :statuses => statuses.compact
end

Registry.add_callback :core, :report_view_widgets, "700_log" do |view_renderer, report|
  view_renderer.render 'reports/log', :report => report
end

# Report status icon
Registry.add_callback :report, :status_icon, "750_inspect_report" do |report|
  if report.kind == "inspect"
    :inspect
  end
end

Registry.add_callback :core, :report_view_widgets, "600_metrics" do |view_renderer, report|
  view_renderer.render 'reports/metrics', :report => report
end
