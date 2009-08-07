# response_for_rc's CI task is just rc's with this stuff loaded

garlic do
  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'
  repo 'response_for', :url => 'git://github.com/ianwhite/response_for'
  repo 'resources_controller', :url => 'git://github.com/ianwhite/resources_controller'
  repo 'response_for_rc', :path => '.'

  ['origin/2-2-stable', 'origin/2-1-stable'].each do |rails|
  
    target "Rails: #{rails}", :tree_ish => rails do
      prepare do
        plugin 'rspec', :as => "rspec"
        plugin 'rspec-rails', :as => "rspec-rails" do
          sh "script/generate rspec -f"
        end
        plugin 'resources_controller'
        plugin 'response_for'
        plugin 'response_for_rc', :clone => true
      end
  
      run do
        cd "vendor/plugins/response_for_rc" do
          sh "rake spec && (cd ../resources_controller; rake spec:generate)"
        end
      end
    end
    
  end
end
