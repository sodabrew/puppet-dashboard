# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tab_to_unless_current (name, url)
    link_to_unless_current name, url do
      content_tag(:span, name, :class => "current")
    end
  end

  def inspector_table(collection, key=nil, value=nil, options={})
    unless collection.is_a?(Hash)
      key ||= :name; value ||= :description

      collection_hash_values = collection.map{ |c|
        [
          key.responds_to?(:call) ? key.call(c) : link_to(c.send(key), c),
          value.responds_to?(:call) ? value.call(c) : c.send(value),
        ]
      }.flatten

      collection = Hash[*collection_hash_values]
    end

    key ||= :key; value ||= :value

    render :partial => 'shared/inspector', :object => collection, :locals => {:key => key.to_s, :value => value.to_s, :options => options}
  end
end
