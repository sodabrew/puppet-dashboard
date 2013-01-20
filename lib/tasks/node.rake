$: << File.dirname(__FILE__)
require 'rake_helpers'

namespace :node do
  desc 'Add a new node'
  task :add => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify node name (name=<hostname>).'
      exit 1
    end

    if Node.find_by_name(name)
      puts 'Node already exists!'
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
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "Add group(s) to a node"
  task :addgroup => :environment do
    node = get_node(ENV['name'])

    unless ENV['group']
      puts 'Must specify group(s) to add to node'
      exit 1
    end

    groups = ENV['group'].split(',').map(&:strip)

    begin
      # ActiveRecord << takes effect immediately without save!
      node.node_groups << [ NodeGroup.find_all_by_name(groups) - node.node_groups ]
      puts "Node groups successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "List groups for a node"
  task :listgroups => :environment do
    node = get_node(ENV['name'])

    begin
      node.node_groups.map(&:name).map{|n| puts n}
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc "Add class(s) to a node"
  task :addclass => :environment do
    node = get_node(ENV['name'])

    unless ENV['class']
      puts 'Must specify class(es) to add to node'
      exit 1
    end

    classes = ENV['class'].split(',').map(&:strip)

    begin
      # ActiveRecord << takes effect immediately without save!
      node.node_classes << [ NodeClass.find_all_by_name(classes) - node.node_classes ]
      puts "Node classes successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "List classes for a node"
  task :listclasses => :environment do
    node = get_node(ENV['name'])

    begin
      node.node_classes.map(&:name).map{|n| puts n}
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc 'Remove a node'
  task :del => :environment do
    begin
      get_node(ENV['name']).destroy
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc 'Replace class(es) for a node'
  task :classes => :environment do
    node = get_node(ENV['name'])

    unless ENV['classes']
      puts 'Must specify class(es) to set on node.'
      exit 1
    end

    classes = ENV['classes'].split(',').map(&:strip)
    node.node_classes = NodeClass.find_all_by_name(classes)

    begin
      node.save!
      puts "Node classes successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc 'Show/Edit/Add parameters for a node'
  task :parameters => :environment do
    node = get_node(ENV['name'])

    # Show parameters
    unless ENV['parameters']
      node.parameters.each do |p|
        puts "#{p.key}=#{p.value}"
      end
      exit
    end

    given_parameters = Hash[ ENV['parameters'].split(',').map do |param|
      param_array = param.split('=',2)
      if param_array.size != 2
        raise ArgumentError, "Could not parse parameter #{param_array.first} given. Perhaps you're missing a '='"
      end
      if param_array[0].nil? or param_array[0].empty?
        raise ArgumentError, "Could not parse parameters. Please check your format. Perhaps you need to name a parameter before a '='"
      end
      if param_array[1].nil? or param_array[1].empty?
        raise ArgumentError, "Could not parse parameters #{param_array.first}. Please check your format"
      end
      param_array
    end ]

    begin
      ActiveRecord::Base.transaction do
        given_parameters.each do |key, value|
          param, *dupes = *node.parameters.find_all_by_key(key)
          if param
            # Change existing parameters
            param.value = value
            param.save!
            # If there were duplicate params from the previous buggy version of
            # this code, remove them
            dupes.each { |d| d.destroy }
          else
            # Create new parameters
            node.parameters.create(:key => key, :value => value)
          end
        end

        node.save!
        puts "Node parameters successfully edited for #{node.name}!"
      end
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc 'Replace groups for a node'
  task :groups => :environment do
    node = get_node(ENV['name'])

    unless ENV['groups']
      puts 'Must specify group(s) to set on node'
      exit 1
    end

    groups = ENV['groups'].split(',').map(&:strip)
    node.node_groups = NodeGroup.find_all_by_name(groups)

    begin
      node.save!
      puts "Node groups successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
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
