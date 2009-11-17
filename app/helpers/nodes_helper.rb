module NodesHelper
  def nodes
    return parent.nodes if parent?
    collection || @nodes || Node.all
  end
end
