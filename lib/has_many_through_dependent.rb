class ActiveRecord::Associations::HasManyThroughAssociation
  private
  def delete_records(records)
    klass         = @reflection.through_reflection.klass
    method_map    = {:destroy => :destroy_all}
    method_name   = method_map.fetch(@reflection.options[:dependent], :delete_all)
    delete_method = klass.method(method_name)

    records.each do |associate|
      delete_method.call(construct_join_attributes(associate))
    end
  end
end
