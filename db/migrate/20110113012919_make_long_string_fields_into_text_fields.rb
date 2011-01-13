class MakeLongStringFieldsIntoTextFields < ActiveRecord::Migration
  def self.up
    change_table :report_logs do |t|
      t.change :message, :text
      t.change :source, :text
      t.change :tags, :text
      t.change :file, :text
    end

    change_table :resource_events do |t|
      t.change :previous_value, :text
      t.change :desired_value, :text
      t.change :historical_value, :text
      t.change :message, :text
    end

    change_table :resource_statuses do |t|
      t.change :file, :text
      t.change :title, :text
      t.change :tags, :text
    end
  end

  def self.down
    change_table :report_logs do |t|
      t.change :message, :string
      t.change :source, :string
      t.change :tags, :string
      t.change :file, :string
    end

    change_table :resource_events do |t|
      t.change :previous_value, :string
      t.change :desired_value, :string
      t.change :historical_value, :string
      t.change :message, :string
    end

    change_table :resource_statuses do |t|
      t.change :file, :string
      t.change :title, :string
      t.change :tags, :string
    end
  end
end
