# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include InheritedResources::DSL
  include PaginateScopeHelper
  include StringHelper

  helper :all # include all helpers, all the time

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  before_filter :set_timezone

  private

  def raise_if_enable_read_only_mode
    raise ReadOnlyEnabledError.new if SETTINGS.enable_read_only_mode
  end

  def raise_unless_using_external_node_classification
    raise NodeClassificationDisabledError.new unless SETTINGS.use_external_node_classification
  end

  rescue_from NodeClassificationDisabledError do |e|
    render :text => "Node classification has been disabled", :content_type => 'text/plain', :status => 403
  end

  def set_timezone
    if SETTINGS.time_zone
      time_zone_obj = ActiveSupport::TimeZone.new(SETTINGS.time_zone)
      raise Exception.new("Invalid timezone #{SETTINGS.time_zone.inspect}") unless time_zone_obj
      Time.zone = time_zone_obj
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def handle_parameters_for(param)
    if params[param] && params[param][:parameters]
      parameter_pairs = params[param][:parameters][:key].zip(params[param][:parameters][:value]).flatten
      params[param][:parameters] = Hash[*parameter_pairs].reject{|k,v| k.blank?}
    else
      params[param][:parameters] = {}
    end
  end

  def set_node_autocomplete_data_sources(source_object)
    @node_data = {
      :class       => '#node_ids',
      :data_source => nodes_path(:format => :json),
      :objects     => source_object.nodes
    }
  end

  def set_group_and_class_autocomplete_data_sources(source_object)
    @class_data = {
      :class       => '#node_class_ids',
      :data_source => node_classes_path(:format => :json),
      :objects     => source_object.node_classes
    } if SETTINGS.use_external_node_classification

    @group_data = {
      :class       => '#node_group_ids',
      :data_source => node_groups_path(:format => :json),
      :objects     => source_object.node_groups
    }
  end
end
