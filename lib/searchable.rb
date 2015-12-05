require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    cols = []
    vals = []
    params.each do |k,v|
      cols << "#{table_name}.#{k} = ?"
      vals << v
    end
    where_query = cols.join(" AND ")
    results = DBConnection.execute(<<-SQL, *vals)
      SELECT
       #{table_name}.*
      FROM
        #{table_name}
      WHERE
       #{where_query}
    SQL
    results.map { |result| self.new(result) }
  end
end
