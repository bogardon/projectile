module IdentityMap

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def metaclass
      class << self; self; end
    end

    def establish_identity_on(attr_name)
      define_method("==") do |other|
        return false unless self.is_a?(other.class)
        self.send(attr_name) == other.send(attr_name)
      end

      metaclass.instance_eval do
        define_method("merge_or_insert") do |json|
          return nil unless json
          attribute = self.get_attributes.find {|a| a[:name] == attr_name}
          key_path = attribute[:key_path]
          identity_key = json.valueForKeyPath(key_path)
          return nil unless identity_key
          old_model = self.identity_map[identity_key]
          if old_model
            old_model.merge_with_json(json)
          else
            self.identity_map[identity_key] = self.new json
          end
          self.identity_map[identity_key]
        end
      end

    end

    def identity_map
      @identity_map ||= Hash.new
    end
  end

  def merge_with_json(json)
    self.class.get_relationships.each do |relationship|
      name = relationship[:name]
      default = relationship[:default]
      key_path = relationship[:key_path]
      json_value = json.valueForKeyPath(key_path)
      self.send("#{name}=", json_value) unless json_value.nil?
    end

    self.class.get_attributes.each do |attribute|
      name = attribute[:name]
      default = attribute[:default]
      key_path = attribute[:key_path]
      json_value = json.valueForKeyPath(key_path)
      self.send("#{name}=", json_value) unless json_value.nil?
    end
  end

end
