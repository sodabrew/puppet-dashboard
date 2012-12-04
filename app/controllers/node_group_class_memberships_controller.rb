class NodeGroupClassMembershipsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_unless_using_external_node_classification
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex
  include ConflictAnalyzer

  def update
    ActiveRecord::Base.transaction do
      old_conflicts = get_current_conflicts(NodeGroupClassMembership.find_by_id(params[:id]).node_group)

      update! do |success, failure|
        success.html {
          membership = NodeGroupClassMembership.find_by_id(params[:id])

          unless(force_update?)
            new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, membership.node_group)
            unless new_conflicts_message.nil?
              html = render_to_string(:template => "shared/_confirm",
                                      :layout => false,
                                      :locals => { :message => new_conflicts_message, :confirm_label => "Update", :on_confirm_clicked_script => "$('force_update').value = 'true'; $('submit_button').click();" })
              render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
              raise ActiveRecord::Rollback
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(membership) }, :content_type => 'application/json'
        };

        failure.html {
          membership = NodeGroupClassMembership.find_by_id(params[:id])
          html = render_to_string(:template => "shared/_error",
                                  :layout => false,
                                  :locals => { :object_name => 'node_group_class_membership', :object => membership })
          render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
        }
      end
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      membership_node_group = NodeGroupClassMembership.find_by_id(params[:id]).node_group
      old_conflicts = force_delete? ? nil : get_current_conflicts(membership_node_group)

      destroy! do |_, format| # only one format is used for destroy (success/failure is not recognized)
                              # TODO recognize and report failed delete
        format.html {

          membership_node_group = NodeGroup.find_by_id(membership_node_group.id)

          unless(force_delete?)
            new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, membership_node_group)

            unless new_conflicts_message.nil?
              html = render_to_string(:template => "shared/_confirm",
                                      :layout => false,
                                      :locals => { :message => new_conflicts_message, :confirm_label => "Delete", :on_confirm_clicked_script => "eval($('delete_button').getAttribute('onclick').replace('?force_delete=false', '?force_delete=true').replace('return false;', '').replace('confirm(\\'Are you sure?\\')', 'true'));" })
              render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
              raise ActiveRecord::Rollback
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(membership_node_group) }, :content_type => 'application/json'
        }
      end
    end
  end

end
