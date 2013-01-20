def get_node
  node_name = ENV['name']
  begin
    node = Node.find_by_name(node_name)

    if node.nil?
      puts "Node #{node_name} doesn't exist!"
      exit 1
    end
  rescue NameError
    puts 'Must specify node name (name=<hostname>).'
    exit 1
  rescue => e
    puts "There was a problem finding the node: #{e.message}"
    exit 1
  end
  node
end

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

    groups = []

    if ENV['groups']
      begin
        ENV['groups'].split(/,\s*/).each do |group|
          ng = NodeGroup.find_by_name(group)
          unless ng.nil?
            groups << ng
          end
        end
      end
    end

    classes = []

    if ENV['classes']
      ENV['classes'].split(/,\s*/).each do |c|
        nc = NodeClass.find_by_name(c)
        unless nc.nil?
          classes << nc
        end
      end
    end

    begin
      node = Node.new(:name => name)
      node.node_groups = groups
      node.node_classes = classes

      node.save!
      puts 'Node successfully created!'
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "Add group(s) to a node"
  task :addgroup => :environment do
    node = get_node

    groups = node.node_groups

    if ENV['group']
      ENV['group'].split(/,\s*/).each do |g|
        ng = NodeGroup.find_by_name(g)
        unless ng.nil?
          groups << ng unless groups.include?(ng)
        end
      end
    else
      puts 'Must specify group(s) to add to node'
      exit 1
    end

    node.node_groups = groups

    begin
      node.save!
      puts "Node groups successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "List groups for a node"
  task :listgroups => :environment do
    node = get_node

    begin
      groups = node.node_groups

      groups.each do |group|
        puts group.name
      end
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc "Add class(s) to a node"
  task :addclass => :environment do
    node = get_node

    classes = node.node_classes

    if ENV['class']
      ENV['class'].split(/,\s*/).each do |c|
        nc = NodeClass.find_by_name(c)
        unless nc.nil?
          classes << nc unless classes.include?(nc)
        end
      end
    else
      puts 'Must specify class(es) to add to node'
      exit 1
    end

    node.node_classes = classes

    begin
      node.save!
      puts "Node classes successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc "List classes for a node"
  task :listclasses => :environment do
    node = get_node

    begin
      classes = node.node_classes

      classes.each do |klass|
        puts klass.name
      end
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc 'Remove a node'
  task :del => :environment do
    begin
      get_node.destroy
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc 'Replace class(es) for a node'
  task :classes => :environment do
    node = get_node

    classes = []

    if ENV['classes']
      ENV['classes'].split(/,\s*/).each do |c|
        nc = NodeClass.find_by_name(c)
        unless nc.nil?
          classes << nc
        end
      end
    else
      puts 'Must specify class(es) to set on node.'
      exit 1
    end

    p classes
    node.node_classes = classes

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
    node = get_node

    # Show parameters
    if ENV['parameters'].nil?
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
    node = get_node

    groups = []

    if ENV['groups']
      ENV['groups'].split(/,\s*/).each do |g|
        ng = NodeGroup.find_by_name(g)
        unless ng.nil?
          groups << ng
        end
      end
    else
      puts 'Must specify group(s) to set on node'
      exit 1
    end

    node.node_groups = groups

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
    regex = false

    if ENV['match']
      regex = ENV['match']
    end

    Node.find(:all).each do |node|
      if regex
        if node.name =~ /#{regex}/
          puts node.name
        end
      else
        puts node.name
      end
    end
  end
end
