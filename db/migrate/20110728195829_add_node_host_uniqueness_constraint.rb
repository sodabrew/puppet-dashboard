class AddNodeHostUniquenessConstraint < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      ALTER TABLE nodes
        ADD CONSTRAINT uc_node_name UNIQUE (name)
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE nodes
        DROP INDEX uc_node_name
    SQL
  end
end
