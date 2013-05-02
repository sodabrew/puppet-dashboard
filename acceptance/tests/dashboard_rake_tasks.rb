test_name "Dashboard Rake Tasks"

dashboard_hosts = hosts.select { |h| h['roles'].include? 'dashboard' }

step "Verify there's at least one dashboard host" do
  assert(dashboard_hosts.length > 0, "No dashboard hosts found!")
end

def build_rake_cmd_string(host, cmd)
  rake_path = host.is_pe? ? "/opt/puppet/bin/rake" : "rake"
  rakefile_path = host.is_pe? ? "/opt/puppet/share/puppet-dashboard/Rakefile" : "/usr/share/puppet-dashboard/Rakefile"
  "RAILS_ENV=production #{rake_path} -f #{rakefile_path} #{cmd}"
end

def run_rake_task(host, cmd)
  result = on(host, build_rake_cmd_string(host, cmd))
  result.stdout.split("\n")
end


#################################
# `nodeclass` tasks
#################################

step "test nodeclass:add, nodeclass:list, nodeclass:del rake tasks" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "nodeclass:add name=fooclass")
    results = run_rake_task(dashboard, "nodeclass:list")
    assert(results.include?("fooclass"), "nodeclass:add should have added 'fooclass'!  nodeclass:list returned: #{results.join("\n")}")

    run_rake_task(dashboard, "nodeclass:del name=fooclass")
    results = run_rake_task(dashboard, "nodeclass:list")
    assert((! results.include?("fooclass")), "nodeclass:del should have removed 'fooclass'!  nodeclass:list returned: #{results.join("\n")}")
  end
end

#################################
# `nodegroup` tasks
#################################

step "test nodegroup:add, nodegroup:list, nodegroup:del rake tasks" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "nodegroup:add name=foogroup")
    results = run_rake_task(dashboard, "nodegroup:list")
    assert(results.include?("foogroup"), "nodegroup:add should have added 'foogroup'!  nodegroup:list returned: #{results.join("\n")}")

    run_rake_task(dashboard, "nodegroup:del name=foogroup")
    results = run_rake_task(dashboard, "nodegroup:list")
    assert((! results.include?("foogroup")), "nodegroup:del should have removed 'foogroup'!  nodegroup:list returned: #{results.join("\n")}")
  end
end


step "test nodegroup:addclass, nodegroup:listclasses, nodegroup:delclass rake tasks" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "nodegroup:add name=foogroup")
    run_rake_task(dashboard, "nodeclass:add name=fooclass")
    run_rake_task(dashboard, "nodeclass:add name=barclass")

    run_rake_task(dashboard, "nodegroup:addclass name=foogroup class=fooclass")
    run_rake_task(dashboard, "nodegroup:addclass name=foogroup class=barclass")

    results = run_rake_task(dashboard, "nodegroup:listclasses name=foogroup")
    assert(results.include?("fooclass"), "nodegroup:addclass should have added 'fooclass'!  nodegroup:listclasses returned: #{results.join("\n")}")
    assert(results.include?("barclass"), "nodegroup:addclass should have added 'barclass'!  nodegroup:listclasses returned: #{results.join("\n")}")

    run_rake_task(dashboard, "nodegroup:delclass name=foogroup class=fooclass")
    run_rake_task(dashboard, "nodegroup:delclass name=foogroup class=barclass")

    results = run_rake_task(dashboard, "nodegroup:listclasses name=foogroup")
    assert((! results.include?("fooclass")), "nodegroup:delclass should have removed 'fooclass'!  nodegroup:listclasses returned: #{results.join("\n")}")
    assert((! results.include?("barclass")), "nodegroup:delclass should have removed 'barclass'!  nodegroup:listclasses returned: #{results.join("\n")}")

    run_rake_task(dashboard, "nodegroup:del name=foogroup")
    run_rake_task(dashboard, "nodeclass:del name=fooclass")
    run_rake_task(dashboard, "nodeclass:del name=barclass")
  end
end


step "test nodegroup:edit rake task" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "nodegroup:add name=foogroup")
    run_rake_task(dashboard, "nodeclass:add name=fooclass")
    run_rake_task(dashboard, "nodeclass:add name=barclass")

    run_rake_task(dashboard, "nodegroup:edit name=foogroup classes=fooclass,barclass")

    results = run_rake_task(dashboard, "nodegroup:listclasses name=foogroup")
    assert(results.include?("fooclass"), "nodegroup:edit should have added 'fooclass'!  nodegroup:listclasses returned: #{results.join("\n")}")
    assert(results.include?("barclass"), "nodegroup:edit should have added 'barclass'!  nodegroup:listclasses returned: #{results.join("\n")}")

    run_rake_task(dashboard, "nodegroup:edit name=foogroup classes=\"\"")

    results = run_rake_task(dashboard, "nodegroup:listclasses name=foogroup")
    assert((! results.include?("fooclass")), "nodegroup:edit should have removed 'fooclass'!  nodegroup:listclasses returned: #{results.join("\n")}")
    assert((! results.include?("barclass")), "nodegroup:edit should have removed 'barclass'!  nodegroup:listclasses returned: #{results.join("\n")}")

    run_rake_task(dashboard, "nodegroup:del name=foogroup")
    run_rake_task(dashboard, "nodeclass:del name=fooclass")
    run_rake_task(dashboard, "nodeclass:del name=barclass")
  end
end


step "test nodegroup:add_all_nodes rake task" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "nodegroup:add name=foogroup")
    run_rake_task(dashboard, "node:add name=foo.localdomain")
    run_rake_task(dashboard, "node:add name=bar.localdomain")

    run_rake_task(dashboard, "nodegroup:add_all_nodes group=foogroup")

    results = run_rake_task(dashboard, "node:listgroups name=foo.localdomain")
    assert(results.include?("foogroup"), "nodegroup:add_all_nodes should have added 'foogroup'!  node:listgroups returned: #{results.join("\n")}")

    results = run_rake_task(dashboard, "node:listgroups name=bar.localdomain")
    assert(results.include?("foogroup"), "nodegroup:add_all_nodes should have added 'foogroup'!  node:listgroups returned: #{results.join("\n")}")

    run_rake_task(dashboard, "node:del name=foo.localdomain")
    run_rake_task(dashboard, "node:del name=bar.localdomain")
    run_rake_task(dashboard, "nodegroup:del name=foogroup")
  end
end


#################################
# `node` tasks
#################################

step "test node:add, node:list, node:del rake tasks" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "node:add name=foo.localdomain")
    results = run_rake_task(dashboard, "node:list")
    assert(results.include?("foo.localdomain"), "node:add should have added 'foo.localdomain'!  node:list returned: #{results.join("\n")}")

    run_rake_task(dashboard, "node:del name=foo.localdomain")
    results = run_rake_task(dashboard, "node:list")
    assert((! results.include?("foo.localdomain")), "node:del should have removed 'foo.localdomain'!  node:list returned: #{results.join("\n")}")
  end
end

step "test node:classes, node:listclasses rake tasks" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "node:add name=foo.localdomain")
    run_rake_task(dashboard, "nodeclass:add name=fooclass")
    run_rake_task(dashboard, "nodeclass:add name=barclass")
    run_rake_task(dashboard, "node:classes name=foo.localdomain classes=fooclass,barclass")

    results = run_rake_task(dashboard, "node:listclasses name=foo.localdomain")
    assert(results.include?("fooclass"), "node:classes should have added 'fooclass'!  node:listclasses returned: #{results.join("\n")}")
    assert(results.include?("barclass"), "node:classes should have added 'barclass'!  node:listclasses returned: #{results.join("\n")}")

    run_rake_task(dashboard, "node:classes name=foo.localdomain classes=\"\"")

    results = run_rake_task(dashboard, "node:listclasses name=foo.localdomain")
    assert((! results.include?("fooclass")), "node:classes should have removed 'fooclass'!  node:listclasses returned: #{results.join("\n")}")
    assert((! results.include?("barclass")), "node:classes should have removed 'barclass'!  node:listclasses returned: #{results.join("\n")}")

    run_rake_task(dashboard, "node:del name=foo.localdomain")
    run_rake_task(dashboard, "nodeclass:del name=fooclass")
    run_rake_task(dashboard, "nodeclass:del name=barclass")
  end
end

step "test node:groups rake task" do
  dashboard_hosts.each do |dashboard|
    run_rake_task(dashboard, "node:add name=foo.localdomain")
    run_rake_task(dashboard, "nodegroup:add name=foogroup")
    run_rake_task(dashboard, "nodegroup:add name=bargroup")
    run_rake_task(dashboard, "node:groups name=foo.localdomain groups=foogroup,bargroup")

    results = run_rake_task(dashboard, "node:listgroups name=foo.localdomain")
    assert(results.include?("foogroup"), "node:groups should have added 'foogroup'!  node:listgroups returned: #{results.join("\n")}")
    assert(results.include?("bargroup"), "node:groups should have added 'bargroup'!  node:listgroups returned: #{results.join("\n")}")

    run_rake_task(dashboard, "node:groups name=foo.localdomain groups=\"\"")

    results = run_rake_task(dashboard, "node:listgroups name=foo.localdomain")
    assert((! results.include?("foogroup")), "node:groups should have removed 'foogroup'!  node:listgroups returned: #{results.join("\n")}")
    assert((! results.include?("bargroup")), "node:groups should have removed 'bargroup'!  node:listgroups returned: #{results.join("\n")}")

    run_rake_task(dashboard, "node:del name=foo.localdomain")
    run_rake_task(dashboard, "nodegroup:del name=foogroup")
    run_rake_task(dashboard, "nodegroup:del name=bargroup")
  end
end
