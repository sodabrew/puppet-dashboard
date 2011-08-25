module FindFromForm
  def find_from_form_names(*names)
    names.reject(&:blank?).map{|name| self.find_by_name(name)}.uniq
  end

  def find_from_form_ids(*ids)
    ids.map{|entry| entry.to_s.split(/[ ,]/)}.flatten.reject(&:blank?).uniq.map{|id| self.find(id)}
  end
end
