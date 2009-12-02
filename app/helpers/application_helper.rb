# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tab_to_unless_current (name, url)
    link_to_unless_current name, url do
      content_tag(:span, name, :class => "current")
    end
  end

  def inspector_table(collection, key=nil, value=nil, options={})
    key, options = nil, key if key.is_a?(Hash)
    unless collection.is_a?(Hash)
      key ||= :name; value ||= :description

      collection_hash_values = collection.map{ |c|
        [
          key.respond_to?(:call) ? key.call(c) : link_to_if(options[:link], c.send(key), c),
          value.respond_to?(:call) ? value.call(c) : c.send(value),
        ]
      }.flatten

      collection = Hash[*collection_hash_values]
    end

    key ||= :key; value ||= :value

    render :partial => 'shared/inspector', :object => collection, :locals => {:key => key.to_s, :value => value.to_s, :options => options}
  end

  def error_messages_for(object_name, options)
    objects = [options.delete(:object)].flatten
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }

    return '' if count.zero?

    header_message = "Please correct #{count > 1 ? "these #{count} errors" : 'this error'}:"
    error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, h(msg)) } }.join

    contents = content_tag(:h3, header_message) +
               content_tag(:ul, error_messages)

    content_tag(:div, contents, :class => 'errors element')
  end
end
