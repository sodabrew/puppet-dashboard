# Set default for YAML.load to unsafe so we don't affect performance
# unnecessarily -- we call it safely explicitly where needed
SafeYAML::OPTIONS[:default_mode] = :unsafe
# Whitelist Symbol objects
# NOTE that the tag is YAML implementation specific (this one is
# specific to 'syck') and thus it needs to be updated whenever
# the yaml implementation is changed
SafeYAML::OPTIONS[:whitelisted_tags] << 'tag:ruby.yaml.org,2002:sym'
