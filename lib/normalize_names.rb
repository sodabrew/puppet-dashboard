module NormalizeNames
  def normalize_name(str)
    result = str.gsub(/[^a-zA-Z0-9]+/, '_').gsub(/^_*/, '').gsub(/_*$/, '').downcase
    result = "unknown_name_#{Time.now.to_i}#{rand(100000).to_i}" if result.blank?
    result
  end  
end
