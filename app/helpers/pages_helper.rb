module PagesHelper
  def percentage(node_count, all_node_count)
    return 0 unless all_node_count > 0
    (100 * node_count / all_node_count.to_f).round(1)
  end
end
