module ActionDispatch
  class Response
    Rack::Utils::SYMBOL_TO_STATUS_CODE.each do |symbol, code|
      define_method("#{symbol}?") { self.code == code.to_s } unless instance_methods.include?("#{symbol}?")
    end
  end
end
