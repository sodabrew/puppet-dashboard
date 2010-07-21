# Return YAML data structure parsed from the current +request.body+.
def yaml_from_response_body
  return YAML.load(response.body)
end

# Return JSON data structure parsed from the current +request.body+.
def json_from_response_body
  return ActiveSupport::JSON.decode(response.body)
end
