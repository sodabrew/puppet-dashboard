module PagesHelper
  def percentage(nodes)
    (100 * nodes.length / @nodes.length.to_f).round(2)
  end
end
