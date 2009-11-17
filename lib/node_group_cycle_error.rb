class NodeGroupCycleError < StandardError
  attr_reader :node_group
  def initialize(node_group)
    @node_group = node_group
    super("The node groups that this node belongs to contain a cycle.")
  end
end
