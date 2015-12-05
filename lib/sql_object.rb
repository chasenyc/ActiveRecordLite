require_relative 'db_connection'
require_relative 'searchable'


class SQLObject
  extend Searchable

  def self.columns
    results = DBConnection.execute2(<<-SQL)
      SELECT
       *
      FROM
        #{table_name}
    SQL
    @columns = results.first.map { |column| column.to_sym }
  end

  def self.finalize!
    generate_column_accessors
  end

  def self.generate_column_accessors
    self.columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end
      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
       #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
       #{table_name}.*
      FROM
        #{table_name}
      WHERE
       #{table_name}.id = ?
    SQL
    return nil if results.empty?
    self.new(results.first)
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", v)
    end
    self.class.finalize!
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    cols = get_sql_insert_columns
    q_marks = get_sql_insert_q_marks(cols.count)

    cols = "(#{cols.join(", ")})"
    q_marks = "(#{q_marks.join(", ")})"

    results = DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} #{cols}
    VALUES
      #{q_marks}
    SQL
    attributes[:id] = DBConnection.last_insert_row_id
  end

  def get_sql_insert_columns
    result = []
    attributes.each { |k,v| result << k.to_s unless v.nil? }
    result
  end

  def get_sql_insert_q_marks(num)
    result = []
    num.times { result << "?" }
    result
  end

  def update
    raise "cannot update nil id" if attributes[:id].nil?

    cols = []
    atts = []

    attributes.each do |k,v|
      cols << k.to_s unless v.nil? || k == :id
      atts << v unless v.nil? || k == :id
    end

    atts << attributes[:id]

    set = []
    cols.each do |value|
      set << "#{value} = ?"
    end

    set = set.join(", ")

    results = DBConnection.execute(<<-SQL, *atts)
      UPDATE
        #{self.class.table_name}
      SET
        #{set}
      WHERE
        id = ?
    SQL
  end

  def save
      self.class.find(attributes[:id]) ? update : insert
  end

end
