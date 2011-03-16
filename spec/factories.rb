Factory.define :node_group do |group|
  group.name { Factory.next(:name) }
end

Factory.define :node_class do |node_class|
  node_class.name { Factory.next(:name) }
end

Factory.define :parameter do |parameter|
  parameter.sequence(:key)   {|n| "Key #{n}"   }
  parameter.sequence(:value) {|n| "Value #{n}" }
end

Factory.define :node do |node|
  node.name { Factory.next(:name) }
end

Factory.define :report do |report|
  report.status "failed"
  report.kind   "apply"
  report.host do |rep|
    if rep.node 
      rep.node.name 
    else
      Factory.next(:name)
    end
  end
  report.time   { Factory.next(:time) }
end

Factory.define :inspect_report, :parent => :report do |inspect|
  inspect.kind 'inspect'
end

Factory.define :resource_status do |status|
end

Factory.define :resource_event do |event|
end

Factory.sequence :name do |n|
  "name_#{n}"
end

Factory.sequence :time do |n|
  # each things created will be 1 hour newer than the last
  # might be a problem if creating more than 1000 objects
  (1000 - n).hours.ago
end
