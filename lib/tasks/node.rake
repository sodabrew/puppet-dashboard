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

  desc 'Remove a node'
  task :del => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify node name (name=<hostname>).'
      exit 1
    end

    begin
      n = Node.find_by_name(name)
      n.destroy
    rescue NoMethodError
      puts 'Node does not exist!'
      exit 1
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc 'Add/Edit class(es) for a node'
  task :classes => :environment do
    node_name = ENV['name']
    begin
      node = Node.find_by_name(name_name)

      if node.nil?
        puts "Node #{node_name} doesn\'t exist!"
        exit 1
      end
    rescue NameError
      puts 'Must specify node name (name=<hostname>).'
      exit 1
    rescue => e
      puts "There was a problem finding the node: #{e.message}"
      exit 1
    end

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

  desc 'Edit/Add parameters for a node'
  task :parameters => :environment do
    node_name = ENV['name']

    if node_name.nil?
      puts 'Must specify node name (name=<hostname>).'
      exit 1
    end

    begin
      node = Node.find_by_name(node_name)

      if node.nil?
        puts "Node #{node_name} doesn\'t exist!"
        exit 1
      end
    rescue => e
      puts "There was a problem finding the node: #{e.message}"
      exit 1
    end

    if ENV['parameters'].nil?
      puts "Must specify node parameters (parameters=param1=val1,param2=val2)"
      exit 1
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

    #Check if we need to change any existing parameters
    node.parameters.each do |parameter|
      if given_parameters.keys.include? parameter.name
        #This deletes the key from the hash and returns the value
        #in a single method call.
        parameter.value = given_parameters.delete parameter.name
      end
    end

    #Create new parameters
    new_parameters = given_parameters.map do |name, parameter|
      Parameter.new :key => name, :value => parameter
    end

    node.parameters = node.parameters + new_parameters

    begin
      node.save!
      puts "Node parameters successfully edited for #{node.name}!"
    rescue => e
      puts "There was a problem saving the node: #{e.message}"
      exit 1
    end
  end

  desc 'Edit/Add groups for a node'
  task :groups => :environment do
    node_name = ENV['name']
    begin
      node = Node.find_by_name(node_name)

      if node.nil?
        puts "Node #{node_name} doesn\'t exist!"
        exit 1
      end
    rescue NameError
      puts 'Must specify node name (name=<hostname>).'
      exit 1
    rescue => e
      puts "There was a problem finding the node: #{e.message}"
      exit 1
    end

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
