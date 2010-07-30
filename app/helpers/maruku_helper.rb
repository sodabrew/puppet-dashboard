module MarukuHelper
  # Return HTML produced by parsing +text+ with , a Markdown parser.
  def markdown(text)
    text.blank? ? nil : content_tag(:div, :class => "markeddown") { Maruku.new(text).to_html }
  end
end
