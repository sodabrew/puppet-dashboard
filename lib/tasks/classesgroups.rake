namespace :nodeclass do
  desc 'List node classes'
  task :list => :environment do
    regex = false

    if ENV['match']
      regex = ENV['match']
    end

    NodeClass.find(:all).each do |nodeclass|
      if regex
        if nodeclass.name =~ /#{regex}/
          puts nodeclass.name
        end
      else
        puts nodeclass.name
      end
    end
  end

  desc 'Add a new node class'
  task :add => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify class name (name=<class>).'
      exit 1
    end

    if NodeClass.find_by_name(name)
      puts 'Class already exists!'
      exit 1
    end

    klass = NodeClass.new(:name => name)

    if klass.save
      puts 'Class successfully created!'
    end
  end

  desc 'Delete a node class'
  task :del => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify class name (name=<class>).'
      exit 1
    end

    begin
      nc = NodeClass.find_by_name(name)
      nc.destroy
    rescue NoMethodError
      puts 'Class doesn\'t exist!'
      exit 1
    rescue => e
      puts e.message
      exit 1
    end
  end
end

namespace :nodegroup do
  desc 'Add a new node group'
  task :add => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify group name (name=<group>).'
      exit 1
    end

    if NodeGroup.find_by_name(name)
      puts 'Group already exists!'
      exit 1
    end

    classes = []

    if ENV['classes']
      ENV['classes'].split(/,\s*/).each do |klass|
        nc = NodeClass.find_by_name(klass)
        unless nc.nil?
          classes << nc
        end
      end
    end

    nodegroup = NodeGroup.new(:name => name)
    nodegroup.node_classes = classes

    if nodegroup.save
      puts 'Group successfully created!'
    end
  end

  desc 'Edit a node group'
  task :edit => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify group name (name=<group>).'
      exit 1
    end

    begin
      nodegroup = NodeGroup.find_by_name(name)

      classes = []

      if ENV['classes']
        ENV['classes'].split(/,\s*/).each do |klass|
          nc = NodeClass.find_by_name(klass)
          unless nc.nil?
            classes << nc
          end
        end
      end

      nodegroup.node_classes = classes

      if nodegroup.save
        puts 'Group successfully edited!'
      end
    rescue NoMethodError
      puts 'Group doesn\'t exist!'
      exit 1
    rescue => e
      puts e.message
      exit 1
    end
  end

  desc 'Delete a node group'
  task :del => :environment do
    if ENV['name']
      name = ENV['name']
    else
      puts 'Must specify group name (name=<group>).'
      exit 1
    end

    begin
      nodegroup = NodeGroup.find_by_name(name)
      nodegroup.destroy
    rescue NoMethodError
      puts 'Group doesn\'t exist!'
      exit 1
    rescue => e
      puts e.message
    end
  end
end
