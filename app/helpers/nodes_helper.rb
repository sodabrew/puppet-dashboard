module NodesHelper
  def nodes
    return parent.nodes if parent?
    collection || @nodes || Node.all
  end

  def node_title_text(node)
    returning node.status_class.titleize do |str|
      str << " " << time_ago_in_words(node.reported_at) << " ago" if node.reported_at
    end
  end
end
