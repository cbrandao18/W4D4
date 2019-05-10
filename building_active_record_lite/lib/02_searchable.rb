require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map{|key| "#{key} = ?"}.join(" AND ")
    there = DBConnection.execute(<<-SQL, *params.values)
      SELECT 
        * 
      FROM 
        #{table_name}
      WHERE 
        #{where_line}
    SQL
    parse_all(there)
  end

end

class SQLObject
  extend Searchable
end
