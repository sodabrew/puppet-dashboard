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

Factory.define :successful_report, :parent => :report do |report|
  report.status 'changed'
end

Factory.define :failing_report, :parent => :report do |report|
  report.status 'failed'
end

Factory.define :inspect_report, :parent => :report do |inspect|
  inspect.kind 'inspect'
end

Factory.define :resource_status do |status|
  status.resource_type 'File'
  status.title { Factory.next(:filename) }
  status.evaluation_time { rand(60)+1 }
  status.file { Factory.next(:filename) }
  status.line { rand(60)+1 }
  status.time { Factory.next(:time) }
  status.change_count 0
  status.out_of_sync_count 0
  status.skipped false
  status.failed false
end

Factory.define :failed_resource, :parent => :resource_status do |status|
  status.failed true
  status.after_create do |status|
    status.events.generate!(:status => 'failed')
    status.change_count += 1
    status.out_of_sync_count += 1
    status.save
  end
end

Factory.define :successful_resource, :parent => :resource_status do |status|
  status.failed false
  status.after_create do |status|
    status.events.generate!(:status => 'success')
    status.change_count += 1
    status.out_of_sync_count += 1
    status.save
  end
end

Factory.define :pending_resource, :parent => :successful_resource do |status|
  status.failed false
  status.after_create do |status|
    status.events.generate!(:status => 'noop')
    status.out_of_sync_count += 1
    status.save
  end
end

Factory.define :resource_event do |event|
end

Factory.define :node do |node|
  node.name { Factory.next(:name) }
end

Factory.define :reported_node, :parent => :node do |node|
  node.after_create do |node|
    Report.generate!(:host => node.name)
    node.reload
  end
end

Factory.define :unresponsive_node, :parent => :reported_node do |node|
  node.after_create do |node|
    node.last_apply_report.update_attributes!(:time => 2.days.ago)
    node.update_attributes!(:reported_at => 2.days.ago)
  end
end

Factory.define :responsive_node, :parent => :reported_node do |node|
  node.after_create do |node|
    node.last_apply_report.update_attributes!(:time => 2.minutes.ago)
    node.update_attributes!(:reported_at => 2.minutes.ago)
  end
end

Factory.define :failing_node, :parent => :responsive_node do |node|
  node.after_create do |node|
    node.last_apply_report.update_attributes!(:status => 'failed')
    node.update_attributes!(:status => 'failed')
  end
end

Factory.define :pending_node, :parent => :responsive_node do |node|
  node.after_create do |node|
    node.last_apply_report.update_attributes!(:status => 'pending')
    node.update_attributes!(:status => 'pending')
    node.last_apply_report.resource_statuses.generate().events.generate(:status => 'noop')
  end
end

Factory.define :changed_node, :parent => :responsive_node do |node|
  node.after_create do |node|
    node.last_apply_report.update_attributes!(:status => 'changed')
    node.last_apply_report.resource_statuses.generate(:status => 'changed').events.generate(:status => 'changed')
    node.update_attributes!(:status => 'changed')
  end
end

Factory.define :unchanged_node, :parent => :responsive_node do |node|
  node.after_create do |node|
    node.last_apply_report.update_attributes!(:status => 'unchanged')
    node.update_attributes!(:status => 'unchanged')
  end
end

Factory.sequence :name do |n|
  "name_#{n}"
end

Factory.sequence :filename do |n|
  File.join('/', *(1..3).map {Factory.next(:name)})
end

Factory.sequence :time do |n|
  # each things created will be 1 hour newer than the last
  # might be a problem if creating more than 1000 objects
  (1000 - n).hours.ago
end
