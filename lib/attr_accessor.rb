class AttrAccessorObject

  def self.my_attr_accessor(*names)
    names.each do |name|
      make_reader(name)
      make_writer(name)
    end
  end

  def self.my_attr_reader(*names)
    names.each do |name|
      make_reader(name)
    end
  end

  def self.my_attr_writer(*names)
    names.each do |name|
      make_writer
    end
  end

  def self.make_reader(name)
    self.send(:define_method, "#{name}") do
      instance_variable_get("@#{name}")
    end
  end

  def self.make_writer(name)
    self.send(:define_method, "#{name}=") do |value|
      instance_variable_set("@#{name}", value)
    end
  end

end
