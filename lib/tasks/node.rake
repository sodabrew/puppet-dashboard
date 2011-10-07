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
    begin
      node = Node.find_by_name(ENV['name'])

      if node.nil?
        puts 'Node doesn\'t exist!'
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

  desc 'Edit/Add groups for a node'
  task :groups => :environment do
    begin
      node = Node.find_by_name(ENV['name'])

      if node.nil?
        puts 'Node doesn\'t exist!'
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
