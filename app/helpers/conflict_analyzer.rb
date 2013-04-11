require 'ostruct'

module ConflictAnalyzer
  class EntityDescriptor
    attr_reader :entity_class, :entity_name

    def initialize(entity_class, entity_name)
      @entity_class = entity_class
      @entity_name = entity_name
    end

    def eql?(other)
      other.is_a?(EntityDescriptor) && other.entity_class == @entity_class && other.entity_name == @entity_name
    end

    def hash
      @entity_name.hash
    end

    def ==(other)
      eql?(other)
    end
  end

  def get_current_conflicts(initial_resource, related_resources = [])
    conflicts = {}

    affected_entities = initial_resource.nil? ? [] : [initial_resource]
    if initial_resource.is_a?(NodeGroup)
      affected_entities += initial_resource.node_group_children
      affected_entities += initial_resource.nodes
    end
    affected_entities += related_resources 

    affected_entities.each do |entity|
      global_conflicts = entity.global_conflicts.nil? ? [] : entity.global_conflicts
      class_conflicts = entity.class_conflicts.nil? ? {} : entity.class_conflicts

      if global_conflicts.length > 0 || class_conflicts.length > 0
        conflicts[EntityDescriptor.new(entity.class, entity.name)] = {
          :global_conflicts => global_conflicts,
          :class_conflicts => class_conflicts
        }
      end
    end

    conflicts
  end

  def get_new_conflicts_message(old_conflicts, initial_resource, related_resources = [])
    new_conflicts = get_new_conflicts(old_conflicts, initial_resource, related_resources)
    if new_conflicts.length > 0
      conflict_message = "You have introduced new conflicts!\\n"
      new_conflicts.keys.each do |entity_desc|
        entity_class = entity_desc.entity_class == NodeGroup ? "Group" : "Node"
        conflict_message = conflict_message + "\\n" + entity_class + ": " + entity_desc.entity_name
        conflicts = new_conflicts[entity_desc]
        if conflicts[:global_conflicts].length > 0
          conflict_message += "\\n  Global conflicts:\\n"
          conflicts[:global_conflicts].each do |conflict|
            conflict_message += "    " + conflict[:name] + " (" + conflict[:value] + "): " +
              conflict[:sources].map{ |source| source.name}.join(",")
          end
          conflict_message += "\\n"
        end
        if conflicts[:class_conflicts].length > 0
          conflict_message += "\\n  Class conflicts:\\n"
          conflicts[:class_conflicts].keys.each do |node_class|
            conflict_message += "    " + node_class.name + ": "
            conflicts[:class_conflicts][node_class].each do |conflict|
              conflict_message += conflict[:name] + " (" + conflict[:value] + ") - " +
                conflict[:sources].map{ |source| source.name}.join(",")
            end
          end
          conflict_message += "\\n"
        end
      end
    else
      conflict_message = nil;
    end

    conflict_message;
  end

  def get_new_conflicts(old_conflicts, initial_resource, related_resources = [])
    current_conflicts = get_current_conflicts(initial_resource, related_resources)
    new_conflicts = {}
    current_conflicts.keys.each do |entity_desc|
      if !old_conflicts.keys.include?(entity_desc)
        new_conflicts[entity_desc] = current_conflicts[entity_desc]
      else
        new_global_conflicts = current_conflicts[entity_desc][:global_conflicts].select { |current|
          existed = false
          old_conflicts[entity_desc][:global_conflicts].each do |old|
            if old[:name] == current[:name] && old[:sources] = current[:sources]
              existed = true
              break
            end
          end

          !existed
        }

        old_class_conflicts = old_conflicts[entity_desc][:class_conflicts];
        current_class_conflicts = current_conflicts[entity_desc][:class_conflicts];
        new_class_conflicts = {}
        current_class_conflicts.keys.each do |clazz|
          if !(old_class_conflicts.include?(clazz))
            new_class_conflicts[clazz] = current_class_conflicts[clazz]
          else
            new_class_conflicts[clazz] = current_class_conflicts[clazz].select { |current|
              existed = false
              old_class_conflicts[clazz].each do |old|
                if old[:name] == current[:name] && old[:sources] = current[:sources]
                  existed = true
                  break
                end
              end

              !existed
            }
          end
          if new_class_conflicts[clazz].length == 0
            new_class_conflicts.delete(clazz)
          end
        end

        if new_global_conflicts.length + new_class_conflicts.length > 0
          new_conflicts[entity_desc] = { :global_conflicts => new_global_conflicts, :class_conflicts => new_class_conflicts }
        end
      end
    end

    new_conflicts
  end
end