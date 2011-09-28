Dir.foreach(Rails.root.join('config', 'installed_plugins')) do |plugin|
  next if plugin =~ /^\.+$/
  plugin_dir = Rails.root.join('vendor', 'plugins', plugin)
  initializers = plugin_dir.join('config', 'initializers')

  if File.directory?(initializers)
    Dir[initializers.join('**', '*.rb')].sort.each do |initializer|
      load(initializer)
    end
  end
end
