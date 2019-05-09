require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
  end

  def self.finalize!
  end

  def self.table_name=(table_name)
    # ...
  end

  #get the name of the table for the class
  def self.table_name
    self.class.name.underscore.pluralize
  end

  # return an array of all the records in the DB
  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  #look up a single record by primary key
  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # @table_name = self.class.underscore
  end

  def attributes
    # ...
  end

  def attribute_values
    # ...
  end

  #insert a new row into the table to represent the SQLObject
  def insert
    # ...
  end

  #update the row with the id of this SQLObject
  def update
    # ...
  end

  #convenience method that either calls insert/update depending on whether or not the SQLObject already exists in the table.
  def save
    # ...
  end

end




# s = 'nowIsTheTime'
# s.split(/(?=[A-Z])/)
# => ["now", "Is", "The", "Time"]


# Order.ancestors #-> [Order, Object, Kernel, BasicObject]
# Order.class.ancestors #->[Class, Module, Object, Kernel, BasicObject]