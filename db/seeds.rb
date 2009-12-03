group = NodeGroup.generate!(:name => 'sample_group')
klass = NodeClass.generate!(:name => 'sample_class')
Node.generate!(:name => 'sample_node', :node_groups => [group], :node_classes => [klass])
