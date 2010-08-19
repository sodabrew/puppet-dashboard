class NodeGroupEdge < ActiveRecord::Base
  validates_presence_of :to_id, :from_id

  belongs_to :to, :class_name => 'NodeGroup'
  belongs_to :from, :class_name => 'NodeGroup'

  validate :validate_dag

  # Performs a depth-first search on all graphs containing this edge,
  # reporting an error and failing validation if there is a loop. Keeps
  # a list of encountered nodes and fails if it encounters the same group
  # twice.
  def validate_dag
    def dfs(group, seen)
      if seen.include?(group)
        self.errors.add_to_base(
          "Creating a dependency from group '#{from.name}' to " \
          + (from.name == to.name ? "itself" : "group '#{to.name}'") \
          + " creates a cycle")
      end
      group.node_groups.each { |grp|
        dfs(grp, seen + [group])
      }
    end

    dfs(self.to,[self.from])
  end
end
