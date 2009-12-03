group = NodeGroup.generate!(:name => 'sample_group')
klass = NodeClass.generate!(:name => 'sample_class')
Node.generate!(:name => 'sample_node', :node_groups => [group], :node_classes => [klass])

Report.create(:report => <<YAML)
--- !ruby/object:Puppet::Transaction::Report 
time: 2009-11-19 17:08:50.631428 -08:00
metrics: 
  time: !ruby/object:Puppet::Util::Metric 
    name: time
    label: Time
    values: 
    - - :config_retrieval
      - Config retrieval
      - 0.185256958007812
    - - :total
      - Total
      - 0.253255844116211
    - - :file
      - File
      - 0.0679988861083984
  resources: !ruby/object:Puppet::Util::Metric 
    name: resources
    label: Resources
    values: 
    - - :out_of_sync
      - Out of sync
      - 1
    - - :total
      - Total
      - 3
    - - :scheduled
      - Scheduled
      - 1
    - - :skipped
      - Skipped
      - 0
    - - :applied
      - Applied
      - 1
    - - :restarted
      - Restarted
      - 0
    - - :failed_restarts
      - Failed restarts
      - 0
    - - :failed
      - Failed
      - 0
  changes: !ruby/object:Puppet::Util::Metric 
    name: changes
    label: Changes
    values: 
    - - :total
      - Total
      - 1
records: {}

logs: 
- !ruby/object:Puppet::Util::Log 
  time: 2009-11-19 17:08:50.557829 -08:00
  level: :info
  tags: 
  - info
  source: Puppet
  message: Applying configuration version '1258679330'
- !ruby/object:Puppet::Util::Log 
  time: 2009-11-19 17:08:50.605975 -08:00
  level: :info
  tags: 
  - info
  source: Filebucket[/tmp/puppet/var/clientbucket]
  message: Adding /tmp/puppet_test(6d0007e52f7afb7d5a0650b0ffb8a4d1)
- !ruby/object:Puppet::Util::Log 
  line: 4
  time: 2009-11-19 17:08:50.607171 -08:00
  level: :info
  tags: 
  - file
  - node
  - default
  - class
  - main
  - info
  version: 1258679330
  file: /tmp/puppet/manifests/site.pp
  source: //Node[default]/File[/tmp/puppet_test]
  message: Filebucketed /tmp/puppet_test to puppet with sum 6d0007e52f7afb7d5a0650b0ffb8a4d1
- !ruby/object:Puppet::Util::Log 
  line: 4
  time: 2009-11-19 17:08:50.625690 -08:00
  level: :notice
  tags: 
  - file
  - node
  - default
  - class
  - main
  - content
  - notice
  version: 1258679330
  file: /tmp/puppet/manifests/site.pp
  source: //Node[default]/File[/tmp/puppet_test]/content
  message: content changed '{md5}6d0007e52f7afb7d5a0650b0ffb8a4d1' to 'unknown checksum'
host: sample_node
YAML
