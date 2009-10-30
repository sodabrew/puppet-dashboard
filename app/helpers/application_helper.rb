# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tab_to_unless_current (name, url)
    link_to_unless_current name, url do
      content_tag(:span, name, :class => "current")
    end
  end
end
