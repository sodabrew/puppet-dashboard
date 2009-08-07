# load up the resources_controller specs

plugins_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
rc_path = File.join(plugins_path, 'resources_controller')

unless File.exist?(rc_path) && File.exist?(File.join(plugins_path, 'response_for'))
  raise "response_for_rc specs require resources_controller and response_for"
end

Dir[File.join("#{rc_path}", '**', '*_spec.rb')].each do |spec|
  require spec
end