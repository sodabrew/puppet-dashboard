$: << File.dirname(__FILE__)
require 'rake_helpers'

namespace :node do
  desc 'Add a new node'
  task :add => :environment do
    if ENV['name']
      name = ENV['name']
    else
      $stderr.puts 'Must specify node name (name=<hostname>).'
      exit 1
    end

    if Node.find_by_name(name)
      $stderr.puts 'Node already exists!'
      exit 1
    end

    # groups and classses are optional, default to [] if not provided
    groups = ENV['groups'].split(',').map(&:strip) rescue []
    classes = ENV['classes'].split(',').map(&:strip) rescue []

    begin
      node = Node.new(:name => name)
      node.node_groups = NodeGroup.find_all_by_name(groups)
      node.node_classes = NodeClass.find_all_by_name(classes)
      node.save!
      puts 'Node successfully created!'
    rescue => e
      $stderr.puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "Add group(s) to a node"
  task :addgroup => :environment do
    node = get_node(ENV['name'])

    unless ENV['group']
      $stderr.puts 'Must specify group(s) to add to node'
      exit 1
    end

    groups = ENV['group'].split(',').map(&:strip)

    begin
      # ActiveRecord << takes effect immediately without save!
      node.node_groups << [ NodeGroup.find_all_by_name(groups) - node.node_groups ]
      puts "Node groups successfully edited for #{node.name}!"
    rescue => e
      $stderr.puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "List groups for a node"
  task :listgroups => :environment do
    node = get_node(ENV['name'])

    begin
      node.node_groups.map(&:name).map{|n| puts n}
    rescue => e
      $stderr.puts e.message
      exit 1
    end
  end

  desc "Add class(s) to a node"
  task :addclass => :environment do
    node = get_node(ENV['name'])

    unless ENV['class']
      $stderr.puts 'Must specify class(es) to add to node'
      exit 1
    end

    classes = ENV['class'].split(',').map(&:strip)

    begin
      # ActiveRecord << takes effect immediately without save!
      node.node_classes << [ NodeClass.find_all_by_name(classes) - node.node_classes ]
      puts "Node classes successfully edited for #{node.name}!"
    rescue => e
      $stderr.puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "List classes for a node"
  task :listclasses => :environment do
    node = get_node(ENV['name'])

    begin
      node.node_classes.map(&:name).map{|n| puts n}
    rescue => e
      $stderr.puts e.message
      exit 1
    end
  end

  desc 'Remove a node'
  task :del => :environment do
    begin
      get_node(ENV['name']).destroy
    rescue => e
      $stderr.puts e.message
      exit 1
    end
  end

  desc 'Replace class(es) for a node'
  task :classes => :environment do
    node = get_node(ENV['name'])

    unless ENV['classes']
      $stderr.puts 'Must specify class(es) to set on node.'
      exit 1
    end

    classes = ENV['classes'].split(',').map(&:strip)
    node.node_classes = NodeClass.find_all_by_name(classes)

    begin
      node.save!
      puts "Node classes successfully edited for #{node.name}!"
    rescue => e
      $stderr.puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  # no description, this is deprecated - use variables instead
  task :parameters => :environment do
    $stderr.puts "node:parameters is deprecated, use node:variables instead"
    ENV['variables'] = ENV['parameters']
    Rake::Task['node:variables'].invoke
  end

  desc 'Show/Edit/Add variables for a list of nodes'
  task :variables => :environment do
    unless ENV['name']
      $stderr.puts 'Must specify node name (name=<hostname>).'
      exit 1
    end

    nodes = ENV['name'].split(',')

    # Show variables
    unless ENV['variables']
      node = get_node(nodes[0])
      node.parameters.each do |p|
        puts "#{p.key}=#{p.value}"
      end
      exit
    end

    given_parameters = Hash[ ENV['variables'].split(',').map do |param|
      param_array = param.split('=',2)
      if param_array.size != 2
        raise ArgumentError, "Could not parse variable #{param_array.first} given. Perhaps you're missing a '='"
      end
      if param_array[0].nil? or param_array[0].empty?
        raise ArgumentError, "Could not parse variables. Please check your format. Perhaps you need to name a variable before a '='"
      end
      if param_array[1].nil? or param_array[1].empty?
        raise ArgumentError, "Could not parse variables #{param_array.first}. Please check your format"
      end
      param_array
    end ]

    begin
      #  Attempt all nodes within the same transaction, so a fail fails all.
      ActiveRecord::Base.transaction do
        nodes.each do |name|
          node = get_node(name)

          given_parameters.each do |key, value|
            param, *dupes = *node.parameters.find_all_by_key(key)
            if param
              # Change existing variables
              param.value = value
              param.save!
              # If there were duplicate params from the previous buggy version of
              # this code, remove them
              dupes.each { |d| d.destroy }
            else
              # Create new variables
              node.parameters.create(:key => key, :value => value)
            end
          end

          node.save!
          puts "Node variables successfully edited for #{node.name}!"
        end
      end
    rescue => e
      $stderr.puts "There was a problem saving the node #{node.name}: #{e.message}"
      exit 1
    end
  end

  desc 'Delete variables for a list of nodes'
  task :delvariables => :environment do
    unless ENV['name']
      $stderr.puts 'Must specify node name (name=<hostname>[,hostname...]).'
      exit 1
    end

    unless ENV['delvariables']
      $stderr.puts 'Must specify variables to delete (delvariables=<key>[,key...]).'
      exit 1
    end

    nodes = ENV['name'].split(',')
    given_parameters = ENV['delvariables'].split(',')

    begin
      #  Attempt all nodes within the same transaction, so a fail fails all.
      ActiveRecord::Base.transaction do
        nodes.each do |name|
          node = get_node(name)

          given_parameters.each do |key, value|
            node.parameters.find_all_by_key(key).map(&:destroy)
          end

          node.save!
          puts "Node variables successfully deleted for #{node.name}!"
        end
      end
    rescue => e
      $stderr.puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc 'Replace groups for a node'
  task :groups => :environment do
    node = get_node(ENV['name'])

    unless ENV['groups']
      $stderr.puts 'Must specify group(s) to set on node'
      exit 1
    end

    groups = ENV['groups'].split(',').map(&:strip)
    node.node_groups = NodeGroup.find_all_by_name(groups)

    begin
      node.save!
      puts "Node groups successfully edited for #{node.name}!"
    rescue => e
      $stderr.puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc 'List nodes'
  task :list => :environment do
    names = Node.all.map(&:name)
    regex = ENV['match'] # if nil, everything matches
    names.grep(/#{regex}/).map{|n| puts n}
  end
end
