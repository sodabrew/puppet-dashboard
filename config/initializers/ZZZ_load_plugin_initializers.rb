Dir[Rails.root.join('config', 'installed_plugins', '*')].sort.each do |plugin|
  dir = Rails.root.join('vendor', 'plugins', plugin)

  Dir[dir.join('config', 'initializers', '**', '*.rb')].sort.each do |file|
    load(file)
  end
end
