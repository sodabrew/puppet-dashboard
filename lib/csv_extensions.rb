require 'csv'

module CsvSerializable
  def to_csv(&blk)
    header = first.class.to_csv_header if first.class.respond_to?(:to_csv_header)
    if blk
      yield header + "\n" if header
      each {|x| yield x.to_csv + "\n"}
      nil
    else
      lines = map(&:to_csv)
      lines.unshift header if header
      lines.join("\n")
    end
  end
end

class Array
  include CsvSerializable
end

class ActiveRecord::NamedScope::Scope
  include CsvSerializable
end

class ActiveRecord::Base
  def self.to_csv_properties
    column_names
  end

  def self.to_csv_header
    CSV.generate_line to_csv_properties
  end

  def to_csv_array
    self.class.to_csv_properties.map {|prop| self.send(prop)}
  end

  def to_csv
    CSV.generate_line to_csv_array
  end
end
