module StringHelper
  def is_md5?(str)
    !!(str =~ /^[0-9a-f]{32}$/)
  end
end
