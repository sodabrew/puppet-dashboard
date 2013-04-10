module ConflictHtml

  def conflict_identifier(obj, conflict_attribute)
    (conflict_attribute) ? obj.send(conflict_attribute) : obj
  end

  def render_conflicts_html(new_conflicts_message, label, script)
    html = render_to_string(:template => "shared/_confirm",
                            :layout => false,
                            :locals => { :message => new_conflicts_message, :confirm_label => label, :on_confirm_clicked_script => script })
    render :json => { :status => "ok", :valid => "false", :confirm_html => html }, :content_type => 'application/json'
    raise ActiveRecord::Rollback
  end

  def update_success_helper(old_conflicts, options)
    klass = options[:class]
    conflict_attribute = options[:conflict_attribute]

    membership = klass.find_by_id(params[:id])

    unless(force_update?)
      new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, conflict_identifier(membership, conflict_attribute))
      if new_conflicts_message
        render_conflicts_html new_conflicts_message, "Update", "jQuery('#force_update').attr('value', 'true'); jQuery('#submit_button').click();"
      end
    end

    render :json => { :status => "ok", :valid => "true", :redirect_to => url_for(membership) }, :content_type => 'application/json'
  end

  def update_failure_helper(options)
    membership = klass.find_by_id(params[:id])
    html = render_to_string(:template => "shared/_error",
                            :layout => false,
                            :locals => { :object_name => klass.to_s.underscore, :object => membership })
    render :json => { :status => "error", :error_html => html }, :content_type => 'application/json'
  end

  def update_helper(options)
    klass = options[:class]
    conflict_attribute = options[:conflict_attribute]

    ActiveRecord::Base.transaction do
      obj = klass.find_by_id(params[:id])
      old_conflicts = force_update? ? nil : get_current_conflicts(conflict_identifier(obj, conflict_attribute))

      update! do |success, failure|
        success.html {
          update_success_helper(old_conflicts, options)
        };

        failure.html {
          update_failure_helper(options)
        }
      end
    end
  end

  def destroy_helper(options)
    klass = options[:class]
    owner_klass = options[:owner_class]
    conflict_attribute = options[:conflict_attribute]
    index_redirect = options[:index_redirect]

    ActiveRecord::Base.transaction do
      member = klass.find_by_id(params[:id])
      membership = (conflict_attribute) ? member.send(conflict_attribute) : member
      old_conflicts = force_delete? ? nil : get_current_conflicts(membership)

      begin
        destroy! do |success, failure|
          success.html {
            membership = owner_klass.find_by_id(membership.id)

            unless(force_delete?)
              new_conflicts_message = get_new_conflicts_message_as_html(old_conflicts, membership)

              if new_conflicts_message
                render_conflicts_html new_conflicts_message, "Delete", "jQuery('#force_delete_button').click();"
              end
            end

            redirection = polymorphic_url( (index_redirect) ? klass : membership )
            render :json => { :status => "ok", :valid => "true", :redirect_to => redirection }, :content_type => 'application/json'
          };

          failure.html {
            render :json => { :status => "error", :error_html => "<p class='error'>An error occurred.<p/>" }, :content_type => 'application/json'
          }
        end
      rescue ActiveRecord::Rollback => e
        raise ActiveRecord::Rollback
      rescue => e
        render :json => { :status => "error", :error_html => "<p class='error'>" + e.message + "<p/>" }, :content_type => 'application/json'
      end
    end
  end
end