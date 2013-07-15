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
          new_model = self.new json
          return nil unless new_model.send(attr_name)
          old_model = self.identity_map[new_model.send(attr_name)]
          self.identity_map[new_model.send(attr_name)] = new_model unless old_model
          old_model.merge_with_model(new_model) if old_model
          (old_model || new_model)
        end
      end
    end

    def identity_map
      @identity_map ||= Hash.new
    end
  end

  def merge_with_model(model)
    return false unless self.is_a?(model.class)
    self.class.relationships.each do |relationship|
      name = relationship[:name]
      model_value = model.instance_variable_get("@#{name}")
      self.send("#{name}=", model_value) unless model_value.nil?
    end

    self.class.attributes.each do |attribute|
      name = attribute[:name]
      model_value = model.instance_variable_get("@#{name}")
      self.send("#{name}=", model_value) unless model_value.nil?
    end
  end

end
