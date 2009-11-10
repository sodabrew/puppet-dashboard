module NodesHelper
  def nodes
    @nodees ||= Node.all
  end
end
