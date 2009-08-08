module NormalizeNames
  def normalize_name(str)
    str.gsub(/[^a-zA-Z0-9]+/, '_').gsub(/^_*/, '').gsub(/_*$/, '').downcase
  end  
end
