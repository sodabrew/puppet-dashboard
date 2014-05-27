# Common functions used by rake tasks

def get_node(node_name)
  begin
    node = Node.find_by_name(node_name)
    unless node
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

def get_group(group_name)
  group = NodeGroup.find_by_name(group_name)
  unless group
    puts "Node group #{group_name} doesn't exist!"
    exit 1
  end
  group
rescue NameError
  puts 'Must specify node group name (name=<groupname>).'
  exit 1
rescue => e
  puts "There was a problem finding the node group: #{e.message}"
  exit 1
end

def get_class(class_name)
  nodeclass = NodeClass.find_by_name(class_name)
  unless nodeclass
    puts "Node class #{class_name} doesn't exist!"
    exit 1
  end
  nodeclass
rescue NameError
  puts 'Must specify node class name (name=<classname>).'
  exit 1
rescue => e
  puts "There was a problem finding the node class: #{e.message}"
  exit 1
end

class TimeString
  UNITS = {
    'min' => 60,
    'hr'  => 3600,
    'day' => 86400,
    'wk'  => 604800,
    'mon' => 2592000,
    'yr'  => 31536000
  }
  KNOWN_UNITS = units.keys.join(', ')

  def interpret_string(str)
    if ENV['upto'] =~ /^\d+$/
      upto = ENV['upto'].to_i
    else
      errors << "You must specify how far up you want to prune as an integer, e.g.: upto={some integer}" \
    end

    if unit = ENV['unit']
      unless units.has_key?(unit)
        errors << "I don't know that unit. Valid units are: #{known_units}" \
      end
    else
      errors << "You must specify the unit of time, e.g.: unit=day" \
    end

    Time.now.gmtime - (upto * str.to_i)
  end
end
