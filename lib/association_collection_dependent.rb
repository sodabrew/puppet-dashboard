class ActiveRecord::Associations::AssociationCollection
  # Replace this collection with +other_array+
  # This will perform a diff and delete/add only records that have changed.
  def replace(other_array)
    other_array.each { |val| raise_on_type_mismatch(val) }

    load_target
    other   = other_array.size < 100 ? other_array : other_array.to_set
    current = @target.size < 100 ? @target : @target.to_set

    transaction do
      records_to_delete = @target.select { |v| !other.include?(v) }
      case @reflection.options.fetch(:dependent, :delete)
      when :delete; delete(records_to_delete)
      when :destroy; destroy(records_to_delete)
      end
      concat(other_array.select { |v| !current.include?(v) })
    end
  end
end
