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

  def report_title_text(report)
    returning report.status.titleize do |str|
      str << " " << time_ago_in_words(report.time) << " ago"
    end
  end

end
