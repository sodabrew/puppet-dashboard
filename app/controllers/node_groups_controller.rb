class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex
  include ConflictAnalyzer
  include ConflictHtml

  def new
    new! do |format|
      format.html {
        set_node_autocomplete_data_sources(@node_group)
        set_group_and_class_autocomplete_data_sources(@node_group)
      }
    end
  end

  def create
    ActiveRecord::Base.transaction do
      related_resources = []
      node_ids_params = params[:node_group][:assigned_node_ids]
      unless node_ids_params.nil?
        node_ids_params.each do |node_ids_param|
          unless node_ids_param.nil? || node_ids_param.length == 0
            node_ids_param.split(/,/).each do |resource_id|
              related_resources << Node.find_by_id(resource_id)
            end
          end
        end
      end
      old_conflicts = force_create? ? nil : get_current_conflicts(nil, related_resources)

      create! do |success, failure|
        success.html {
          node_group = NodeGroup.find_by_name(params[:node_group][:name])

          unless(force_create?)

            new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, node_group)
            if new_conflicts_message
              render_conflicts_html new_conflicts_message, "Create", "jQuery('#force_create').attr('value', 'true'); jQuery('#submit_button').click();"
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(node_group) }, :content_type => 'application/json'
        };

        failure.html {
          set_node_autocomplete_data_sources(@node_group)
          set_group_and_class_autocomplete_data_sources(@node_group)
          html = render_to_string(:template => "shared/_error",
                                  :layout => false,
                                  :locals => { :object_name => 'node_group', :object => @node_group })
          render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
        }
      end
    end
  end

  def edit
    edit! do |format|
      format.html {
        set_node_autocomplete_data_sources(@node_group)
        set_group_and_class_autocomplete_data_sources(@node_group)
      }
    end
  end

  def update
    ActiveRecord::Base.transaction do
      old_conflicts = force_update? ? nil : get_current_conflicts(NodeGroup.find_by_id(params[:id]))

      update! do |success, failure|
        success.html {
          update_success_helper old_conflicts, :class => NodeGroup, :conflict_attribute => nil
        };

        failure.html {
          node_group = NodeGroup.find_by_id(params[:id])

          set_node_autocomplete_data_sources(node_group)
          set_group_and_class_autocomplete_data_sources(node_group)
          html = render_to_string(:template => "shared/_error",
                                  :layout => false,
                                  :locals => { :object_name => 'node_group', :object => node_group })
          render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
        }
      end
    end
  end

  def destroy
    destroy_helper  :class => NodeGroup,
                    :owner_class => NodeGroup,
                    :index_redirect => true
  end

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_id_or_name!(params[:id]))
  end
end
