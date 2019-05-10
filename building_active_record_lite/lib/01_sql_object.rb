require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if !@columns
      data = DBConnection.execute2(<<-SQL)
        SELECT 
          *
        FROM
          #{self.table_name}
      SQL
      @columns = data.first.map{ |el| el.to_sym }
    else
      return @columns
    end
  end

  def self.finalize!
    self.columns.each do |name|

      #get method
      define_method(name) do
        self.attributes[name]
      end

      #set method
      define_method("#{name}=") do |value|
        self.attributes[name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  
  #get the name of the table for the class
  def self.table_name
    @table_name ||= self.name.underscore.pluralize
  end

  # return an array of all the records in the DB
  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT #{table_name}.* FROM #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    els = []
    results.each do |el|
      els << self.new(el)
    end
    els
  end

  #look up a single record by primary key
  def self.find(id)
    parse_all(
      DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    ).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      #convert attr_name to symbol
      attr_name = attr_name.to_sym
      #check if attr_name is in columns, raise error if its not
      if self.class.columns.include?(attr_name)
        #use .send to call the setter method for each attr_name
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes = {} if !@attributes
    return @attributes
  end

  #returns an array of the values for each attribute.
  #calling Array#map on SQLObject::columns, calling send on the instance to get the value.
  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  #insert a new row into the table to represent the SQLObject
  def insert
    num_columns = col_names = self.class.columns[1..-1].length
    col_names = self.class.columns[1..-1].join(", ")
    q_marks = Array.new( num_columns, "?").join(", ")

    attributes = attribute_values[1..-1]
    DBConnection.execute(<<-SQL, *attributes)
      INSERT INTO 
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  #update the row with the id of this SQLObject
  def update
    set_line = self.class.columns.map { |name| name.to_s + " = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

 #convenience method that either calls insert/update depending on whether or not the SQLObject already exists in the table.
  def save
    id.nil? ? insert : update
  end

end




# s = 'nowIsTheTime'
# s.split(/(?=[A-Z])/)
# => ["now", "Is", "The", "Time"]


# Order.ancestors #-> [Order, Object, Kernel, BasicObject]
# Order.class.ancestors #->[Class, Module, Object, Kernel, BasicObject]