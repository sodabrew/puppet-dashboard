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
      }

      collection = collection_hash_values
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
    content_tag(:div, :class => 'actionbar') do
      pagination = if scope.respond_to?(:total_pages) && scope.total_pages > 1
        [
        more_link ? content_tag(:span, :class => 'pagination') { link_to('More &raquo;', more_link) } : will_paginate(scope),
        content_tag(:div, :class => 'pagination') do
          ' | '
        end
        ]
      else
        []
      end
      pagination_sizer = more_link ? [] : [
        pagination_sizer_for(scope),
        tag(:br, :class=> 'clear')
      ]
      pagination + pagination_sizer
    end
  end

  def pagination_sizer_for(scope)
    return nil if ! scope.first
    return nil if ! scope.first.class.respond_to? :per_page
    content_tag(:div, :class => 'pagination') do
      [content_tag(:span){ "Per page: " }] +
      [scope.first.class.per_page, 100, :all].map do |n|
        if (params[:per_page] || scope.per_page.to_s) == n.to_s
          content_tag(:span, :class => "current"){ n }
        else
          link_to(n, params.merge({:per_page => n}))
        end
      end
    end
  end

  def icon(name)
    image_tag "icons/#{name}.png"
  end

  # Return status icon for the +node+.
  def node_status_icon(node)
    report_status_icon(node.last_apply_report)
  end

  # Return status icon for the +report+.
  def report_status_icon(report)
    render 'reports/report_status_icon', :report => report
  end

  # Return status table cell with icon for the +report+.
  def report_status_td(report)
    render 'reports/report_status_td', :report => report
  end

  # Return 'sucess' or 'failure' CSS class name if the numeric +count+ is
  # non-zero and this boolean +measures_failure+.
  def counter_class(count, measures_failure)
    (count > 0 && measures_failure) ? 'failure' : 'success'
  end

  # Return +collection+ of Puppet::Util::Log objects sorted by their severity level.
  def puppet_log_sorter(collection)
    collection.sort_by do |instance|
      case instance.level.to_sym
      when :err
        0
      when :warning
        10
      when :notice
        20
      when :info
        30
      when :debug
        50
      else
        40
      end
    end
  end

  def wrap_on_slashes(str)
    (h str).gsub("/","/<wbr />")
  end

  # Return HTML describing the search if one is present in params[:q].
  def describe_search_if_present
    if params[:q].present?
      return "matching &ldquo;#{h params[:q]}&rdquo;"
    end
  end

  # Return HTML describing that no matches were found using the +message+.
  # The +message+ is raw HTML, escape it yourself if necessary.
  def describe_no_matches_as(message)
    return "<span class='nomatches'>&mdash; #{message} &mdash;</span>"
  end

  # Return HTML describing that no matches were found for the collection
  # described as +name+ of the optional +subject+. also describe the search if
  # one is present.
  #
  # Example:
  #
  #   # Returns 'No reports found' message if no search is active
  #   # Returns 'No reports found matching "foo"' message if searching for "foo"
  #   describe_no_matches_for(:reports)
  #
  #   # Returns 'No reports found for this node' message if no search is active
  #   # Returns 'No reports found for this node matching "foo"' message if searching for "foo"
  #   describe_no_matches_for(:reports, :node)
  def describe_no_matches_for(name, subject=nil)
    message = "No #{h name.to_s.downcase} found"
    message << " for this #{h subject.to_s.downcase}" if subject
    message << " #{describe_search_if_present}" if params[:q]
    return describe_no_matches_as(message)
  end

  # Return a jQuery document ready Javascript block to add
  # tokenizer/autocomplete functionality to one or more inputs.  The
  # helper expects to be passed a hash per input to "tokenize".
  #
  # Each input is expected to be passed as a hash in the following form:
  #   {
  #     :class       => '#css_selector',
  #     :data_source => '/get/data/here.json',
  #     :objects     => [ data_to_pre_populate_input, ... ]
  #   }
  # Where each object must respond to id, and name.
  #
  # Example:
  #   tokenize_input_classes(
  #     {:class => '#node_class_ids', :data_source => '/node_classes.json', :objects => @node_classes},
  #     {:class => '#node_group_ids', :data_source => '/node_groups.json',  :objects => @node_groups}
  #   )
  #
  # This would result in a Javascript snippit such as the following:
  #   jQuery(document).ready(function(J) {
  #     J('#node_class_ids').tokenInput('/node_classes.json', {
  #       prePopulate: [{"name":"another_class","id":2},{"name":"third_class","id":3}]
  #     });
  #     J('#node_group_ids').tokenInput('/node_groups.json', {
  #       prePopulate: []
  #     });
  #   });
  def tokenize_input_class(*inputs)
    javascript = "jQuery(document).ready(function(J) {\n"
    inputs.each do |input|
      javascript << "  J('#{input[:class]}').tokenInput('#{input[:data_source]}', {\n"
      javascript << "    prePopulate: #{input[:objects].map {|object| {:id => object.id, :name => object.name}}.to_json}\n"
      javascript << "  });\n"
    end
    javascript << "});"
    return javascript
  end

  # Asynchronously loads data from a URL and injects it into the element specified. The
  # element must be in the DOM before the query, or it may fail. Element should be
  # specified in CSS selector form (eg. "#element" for the object with id="element").
  def load_asynchronously(element, url)
    javascript = "jQuery.get('#{url}', function(data) { jQuery('#{element}').html(data) })"
  end

  def generate_unique_id
    @unique_id_counter ||= 0
    @unique_id_counter += 1
  end
end
