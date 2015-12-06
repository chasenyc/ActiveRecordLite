require 'active_support/inflector'

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.downcase}_id".to_sym
    @class_name = options[:class_name] || "#{name.to_s.camelcase.singularize}"
    @primary_key = options[:primary_key] || :id
  end
end
