Registry.add_callback :core, :node_view_widgets, "100_description" do |view_renderer, node|
  view_renderer.render 'nodes/description', :node => node
end

Registry.add_callback :core, :node_view_widgets, "200_node_classification" do |view_renderer, node|
  view_renderer.render 'nodes/node_classification', :node => node
end

Registry.add_callback :core, :node_view_widgets, "300_inventory_service" do |view_renderer, node|
  view_renderer.render 'nodes/inventory_service', :node => node
end

Registry.add_callback :core, :node_view_widgets, "400_reports" do |view_renderer, node|
  view_renderer.render 'nodes/reports', :node => node
end

Registry.add_callback :core, :node_view_widgets, "600_inspections" do |view_renderer, node|
  view_renderer.render 'nodes/inspections', :node => node
end

Registry.add_callback :core, :node_view_widgets, "700_activity" do |view_renderer, node|
  view_renderer.render 'nodes/activity', :node => node
end
