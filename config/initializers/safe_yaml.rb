require 'safe_yaml'

# Set default for YAML.load to unsafe so we don't affect performance
# unnecessarily -- we call it safely explicitly where needed
SafeYAML::OPTIONS[:default_mode] = :unsafe

# Whitelist Symbol objects
SafeYAML::OPTIONS[:whitelisted_tags] << 'tag:ruby.yaml.org,2002:sym' #syck
SafeYAML::OPTIONS[:whitelisted_tags] << '!ruby/sym' #psych
