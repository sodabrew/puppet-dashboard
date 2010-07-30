[
  "#{RAILS_ROOT}/public/javascripts/all.js",
  "#{RAILS_ROOT}/public/stylesheets/all.css",
].each do |filename|
  FileUtils.rm(filename) if File.exist?(filename)
end
