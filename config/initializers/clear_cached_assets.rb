[
  "#{Rails.root}/public/javascripts/all.js",
  "#{Rails.root}/public/stylesheets/all.css",
].each do |filename|
  FileUtils.rm(filename) if File.exist?(filename)
end
