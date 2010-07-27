# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def truncated_node_sentence(nodes, options={})
    truncated_sentence(5, nodes, :more => link_to("%d more", options[:more_link])){|node| link_to node.name, node}
  end

  def truncated_sentence(max, items, options={}, &block)
    more_text = options[:more] || "%d more"
    extra = items.size - max
    items_to_list = items[0,max]

    items_to_list.map!(&block) if block
    items_to_list << more_text % extra if items.size > max
    items_to_list.to_sentence
  end

  def tab_to_unless_current (name, url)
    link_to_unless_current name, url do
      content_tag(:span, name, :class => "current")
    end
  end

  # Return HTML with a fancy table for a collection of values.
  #
  # Arguments:
  # * +collection+: Either an array-of-arrays with each element containing a key
  #   and value to display as columns, or a hash. Required.
  # * +key+: The hash key to display in the table's key column if +collection+ is a
  #   hash. Optional.
  # * +value+: The hash key to display in the table's value column if +collection+
  #   is a hash. If false, won't set or display the table's value column. Optional.
  # * options: A hash of options, see below.
  #
  # Options:
  # * :caption => String to display as a table caption.
  # * :link => Should the key column be made into a link? Boolan.
  # * :key_only => Only display the key column? Will be set to true if +value+ is false.
  def inspector_table(collection, key=nil, value=nil, options={})
    key, options = nil, key if key.is_a?(Hash)
    unless collection.is_a?(Hash)
      key ||= :name
      value = :description if value.nil?
      options[:key_only] = true if value == false

      collection_hash_values = collection.map{ |c|
        [
          key.respond_to?(:call) ? 
            key.call(c) : 
            link_to_if(options[:link], c.send(key), c),
          value ? 
            (value.respond_to?(:call) ? value.call(c) : c.send(value)) : 
            false
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

  def active_if(condition)
    condition ? 'active' : ''
  end

  # Focus the form input on the +target+ id element, e.g. "node_name".
  def focus(target)
    # javascript_tag "jQuery(document).ready(function () { '##{h target.to_s}').focus(); });"
    javascript_tag <<-HERE
      jQuery(document).ready( function() {
        jQuery('##{h target.to_s}').focus().focus();
      });
    HERE
  end

  # Return HTML for this +form+'s header.
  def header_for(form)
    content_tag(:h2, :class => "header") do
      (form.object.new_record? ? "Add" : "Edit") + " " + form.object.class.name.titleize.downcase
		end
  end

  include WillPaginate::ViewHelpers

  # Return HTML with pagination controls for displaying an ActiveRecord +scope+.
  def pagination_for(scope, more_link=nil)
    if scope.respond_to?(:total_pages) && scope.total_pages > 1
      content_tag(:div, :class => 'actionbar') do
        [
          more_link ? content_tag(:span, :class => 'pagination') { link_to('More &raquo;', more_link) } : will_paginate(scope),
          tag(:br, :class=> 'clear')
        ]
      end
    end
  end

  def icon(name)
    image_tag "icons/#{name}.png"
  end

  # Return status icon for the +node+.
  def node_status_icon(node)
    report_status_icon(node.last_report)
  end

  # Return status icon for the +report+.
  def report_status_icon(report)
    render 'reports/report_status_icon', :report => report
  end

  # Return status table cell with icon for the +report+.
  def report_status_td(report)
    render 'reports/report_status_td', :report => report
  end

end
