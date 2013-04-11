class NodeGroupsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex
  include ConflictAnalyzer

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
            unless new_conflicts_message.nil?
              html = render_to_string(:template => "shared/_confirm",
                                      :layout => false,
                                      :locals => { :message => new_conflicts_message, :confirm_label => "Create", :on_confirm_clicked_script => "$('force_create').value = 'true'; $('submit_button').click();" })
              render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
              raise ActiveRecord::Rollback
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
          node_group = NodeGroup.find_by_id(params[:id])
 
          unless(force_update?)
 
            new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, node_group)
            unless new_conflicts_message.nil?
              html = render_to_string(:template => "shared/_confirm",
                                      :layout => false,
                                      :locals => { :message => new_conflicts_message, :confirm_label => "Update", :on_confirm_clicked_script => "$('force_update').value = 'true'; $('submit_button').click();" })
              render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
              raise ActiveRecord::Rollback
            end
          end
 
          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(node_group) }, :content_type => 'application/json'
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
    ActiveRecord::Base.transaction do
      old_conflicts = force_delete? ? nil : get_current_conflicts(NodeGroup.find_by_id(params[:id]))

      destroy! do |_, format| # only one format is used for destroy (success/failure is not recognized)
                              # TODO recognize and report failed delete
        format.html {

          unless(force_delete?)
            node_group = NodeGroup.find_by_id(params[:id])
            new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, node_group)

            unless new_conflicts_message.nil?
              html = render_to_string(:template => "shared/_confirm",
                                      :layout => false,
                                      :locals => { :message => new_conflicts_message, :confirm_label => "Delete", :on_confirm_clicked_script => "eval($('delete_button').getAttribute('onclick').replace('?force_delete=false', '?force_delete=true').replace('return false;', '').replace('confirm(\\'Are you sure?\\')', 'true'));" })
              render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
              raise ActiveRecord::Rollback
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => node_groups_path }, :content_type => 'application/json'
        }
      end
    end
  end
end
