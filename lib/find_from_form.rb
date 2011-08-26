module FindFromForm
  def find_from_form_names(*names)
    names.reject(&:blank?).map{|name| self.find_by_name(name)}.uniq
  end

  def find_from_form_ids(*ids)
    ids.map{|entry| entry.to_s.split(/[ ,]/)}.flatten.reject(&:blank?).uniq.map{|id| self.find(id)}
  end

  def assigns_related(*models)
    models.each do |model|
      model = model.to_s
      attr_accessor "assigned_#{model}_names"
      attr_accessor "assigned_#{model}_ids"
      before_validation "assign_#{model.pluralize}"

      define_method("assign_#{model.pluralize}") do
        names = instance_variable_get("@assigned_#{model}_names")
        ids = instance_variable_get("@assigned_#{model}_ids")
        begin
          return true unless ids || names
          if !SETTINGS.use_external_node_classification and model == 'node_class'
            raise NodeClassificationDisabledError.new 
          end
          my_models = []
          my_models << model.camelize.constantize.find_from_form_names(*names) if names
          my_models << model.camelize.constantize.find_from_form_ids(*ids)     if ids

          send("#{model.pluralize}=", my_models.flatten.uniq)
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
          self.errors.add_to_base(e.message)
          return false
        end
      end
    end
  end
end
