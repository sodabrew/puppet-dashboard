module FindByIdOrName
  def find_by_id_or_name!(identifier)
    case identifier
    when Integer, /^\d+$/
      find_by_id!(identifier)
    else
      find_by_name!(identifier)
    end
  end
end
