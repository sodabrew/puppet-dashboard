
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
      ENV['groups'].split(/,\s*/).each do |group|
        ng = NodeGroup.find_by_name(group)
        unless ng.nil?
          groups << ng
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

    node = Node.new(:name => name)
    node.node_groups = groups
    node.node_classes = classes
    
    if node.save
      puts 'Node successfully created!'
    end
  end

  desc 'Edit/Add class(es) for a node'
  task :classes => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify node name (name=<hostname>).'
      exit 1
    end

    node = Node.find_by_name(name)

    if node.nil?
      puts 'Node doesn\'t exist!'
      exit 1
    end

    classes = []

    if ENV['classes']
      ENV['classes'].split(/,\s*/).each do |c|
        puts c
        nc = NodeClass.find_by_name(c)
        unless nc.nil?
          classes << nc
        end
      end
    else
      puts 'Must specify class(es) to set on node'
    end

    p classes
    node.node_classes = classes

    if node.save
      puts "Node classes successfully edited for #{name}!"
    end
  end
end
