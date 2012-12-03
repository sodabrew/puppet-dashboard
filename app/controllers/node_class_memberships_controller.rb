class NodeClassMembershipsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :raise_unless_using_external_node_classification
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  include SearchableIndex
  include ConflictAnalyzer

  def update
    ActiveRecord::Base.transaction do
      old_conflicts = get_current_conflicts(NodeClassMembership.find_by_id(params[:id]).node)

      update! do |success, failure|
        success.html {
          membership = NodeClassMembership.find_by_id(params[:id])

          unless(force_update?)
            new_conflicts_message = get_new_conflicts_message(old_conflicts, membership.node)
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
          membership = NodeClassMembership.find_by_id(params[:id])
          html = render_to_string(:template => "shared/_error",
                                  :layout => false,
                                  :locals => { :object_name => 'node_class_membership', :object => membership })
          render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
        }
      end
    end
  end

  def destroy
    membership_node = NodeClassMembership.find_by_id(params[:id]).node

    ActiveRecord::Base.transaction do
      old_conflicts = get_current_conflicts(membership_node)

      destroy! do |_, format| # only one format is used for destroy (success/failure is not recognized)
                              # TODO recognize and report failed delete

        membership_node = Node.find_by_id(membership_node.id)

        format.html {

          unless(force_delete?)
            new_conflicts_message = get_new_conflicts_message(old_conflicts, membership_node)

            unless new_conflicts_message.nil?
              html = render_to_string(:template => "shared/_confirm",
                                      :layout => false,
                                      :locals => { :message => new_conflicts_message, :confirm_label => "Delete", :on_confirm_clicked_script => "eval($('delete_button').getAttribute('onclick').replace('?force_delete=false', '?force_delete=true').replace('return false;', '').replace('confirm(\\'Are you sure?\\')', 'true'));" })
              render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
              raise ActiveRecord::Rollback
            end
          end

          render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(membership_node) }, :content_type => 'application/json'
        }
      end
    end
  end

end
