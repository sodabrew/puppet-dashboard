# This is straight out of the comments in actionpack/lib/action_controller/metal/renderers.rb
ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, :type => Mime[:csv],
    :disposition => "attachment; filename=#{filename}.csv"
end

ActionController::Renderers.add :yaml do |obj, options|
  str = obj.respond_to?(:to_yaml) ? obj.to_yaml : obj.to_s
  send_data str, :type => Mime[:yaml]
end
