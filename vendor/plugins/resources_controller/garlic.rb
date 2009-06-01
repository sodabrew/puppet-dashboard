garlic do
  repo 'resources_controller', :path => '.'
  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'

  ['2-2-stable', '2-1-stable', '2-0-stable'].each do |rails|

    target rails, :tree_ish => "origin/#{rails}" do
      prepare do
        plugin 'resources_controller', :clone => true
        plugin 'rspec'
        plugin 'rspec-rails' do
          sh "script/generate rspec -f"
        end
      end
  
      run do
        cd "vendor/plugins/resources_controller" do
          sh "rake rcov:verify && rake spec:generate"
        end
      end
    end

  end
end
