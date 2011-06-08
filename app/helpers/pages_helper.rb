module PagesHelper
  def percentage(nodes)
    (100 * nodes.length / @all_nodes.length.to_f).round(2)
  end
end
