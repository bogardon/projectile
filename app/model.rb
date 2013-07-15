class Model
  include ValueTransformer

  # All objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
  register_value_transformer :type => :boolean,
                             :to => (lambda {|value| !!value}),
                             :from => (lambda {|value| value})

  register_value_transformer :type => :integer,
                             :to => (lambda {|value| value.to_i}),
                             :from => (lambda {|value| value})

  register_value_transformer :type => :float,
                             :to => (lambda {|value| value.to_f}),
                             :from => (lambda {|value| value})

  register_value_transformer :type => :date,
                             :to => (lambda {|value| value.is_a?(Time) ? value : date_formatter.dateFromString(value.to_s)}),
                             :from => (lambda {|value| date_formatter.stringFromDate(value)})

  register_value_transformer :type => :url,
                             :to => (lambda {|value| value.is_a?(NSURL) ? value : NSURL.URLWithString(value.to_s)}),
                             :from => (lambda {|value| value.to_s})

  register_value_transformer :type => :string,
                             :to => (lambda {|value| value.to_s}),
                             :from => (lambda {|value| value})

  class << self

    def attributes
      @attributes ||= []
    end

    def set_attribute(attribute)
      name = attribute[:name]
      type = attribute[:type]
      default = attribute[:default]
      attribute[:key_path] ||= name

      attr_accessor name

      # setter
      define_method("#{name}=") do |value|
        transformer = self.class.value_transformers[type][:to]
        new_value = transformer.call(value) if transformer
        self.willChangeValueForKey name
        self.instance_variable_set("@#{name}", new_value)
        self.didChangeValueForKey name
      end

      self.attributes << attribute
    end

    def relationships
      @relationships ||= []
    end

    def set_relationship(relationship)
      name = relationship[:name]
      class_name = relationship[:class_name]
      default = relationship[:default]
      relationship[:key_path] ||= name

      attr_accessor name

      # setter
      define_method("#{name}=") do |value|
        cls = Kernel.const_get(class_name.capitalize)
        new_value = case value
        when Hash
          cls.include?(IdentityMap) ? cls.merge_or_insert(value) : cls.new(value)
        when Array
          value.map {|e| (e.is_a?(cls) ? e : (cls.include?(IdentityMap) ? cls.merge_or_insert(e) : cls.new(e)))}
        when cls
          value
        else
          nil
        end if value

        self.willChangeValueForKey name
        self.instance_variable_set("@#{name}", new_value)
        self.didChangeValueForKey name
      end

      self.relationships << relationship
    end
  end

  def to_hash
    # TODO
    hash = {}
    self.class.attributes.each do |attribute|
      name = attribute[:name]
      key_path = attribute[:key_path]
      type = attribute[:type]
      default = attribute[:default]

      # grab value
      model_value = self.send("#{name}")

      # create intermediate hashes
      components = key_path.split(".")
      inner_hash = hash
      components.each_with_index do |component, index|
        if index == components.count-1
          transformer = self.class.value_transformers[type][:from]
          inner_hash[component] = transformer.call(model_value)
        else
          hash[component] ||= Hash.new
          inner_hash = hash[component]
        end
      end
    end

    self.class.relationships.each do |relationship|
      name = relationship[:name]
      key_path = relationship[:key_path]
      class_name = relationship[:class_name]

      model_value = self.send("#{name}")

      components = key_path.split(".")
      inner_hash = hash
      components.each_with_index do |component, index|
        if index == components.count-1
          inner_hash[component] = case model_value
          when Array
            model_value.map {|e| e.to_hash}
          when Model
            model_value.to_hash
          else
          end
        else
          hash[component] ||= Hash.new
          inner_hash = hash[component]
        end
      end
    end

    hash
  end

  def initialize(json={})
    self.class.relationships.each do |relationship|
      name = relationship[:name]
      default = relationship[:default]
      key_path = relationship[:key_path]
      json_value = json.valueForKeyPath(key_path)
      value_to_send = json_value.nil? ? default : json_value
      self.send("#{name}=", value_to_send) unless value_to_send.nil?
    end

    self.class.attributes.each do |attribute|
      name = attribute[:name]
      default = attribute[:default]
      key_path = attribute[:key_path]
      json_value = json.valueForKeyPath(key_path)
      value_to_send = json_value.nil? ? default : json_value
      self.send("#{name}=", value_to_send) unless value_to_send.nil?
    end
  end
end
