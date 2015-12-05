require_relative 'searchable'
require 'active_support/inflector'

module Associatable

  def belongs_to(name, opts = {})
    options = BelongsToOptions.new(name, opts)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      model_class = options.model_class
      result = model_class.where({ options.primary_key => foreign_key }).first
    end
  end

  def has_many(name, opts = {})
    options = HasManyOptions.new(name, self, opts)
    assoc_options[name] = options

    define_method(name) do
       primary_key = self.send(options.primary_key)
       model_class = options.model_class
       result = model_class.where({ options.foreign_key => primary_key })
    end
  end

  def has_one_through(name, through_name, source_name)
    through = self.assoc_options[through_name]
    source = through.model_class.assoc_options[source_name]

    define_method(name) do
      results = DBConnection.execute(<<-SQL)
        SELECT
          houses.*
        FROM
          #{through.table_name}
        JOIN
          #{source.table_name} ON #{through.table_name}.#{source.foreign_key} = #{source.table_name}.#{source.primary_key}
        WHERE
          #{through.table_name}.#{through.primary_key} = #{self.send(through.foreign_key)}
      SQL
      source.model_class.new(results.first)
    end
  end

  def assoc_options
    @results ||= {}
  end
end
