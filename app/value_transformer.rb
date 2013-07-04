module ValueTransformer
  module ClassMethods
    def date_formatter
      return @@date_formatter if @@date_formatter
      formatter = NSDateFormatter.alloc.init
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      @@date_formatter = formatter
    end

    def value_transformers
      @@value_transformers ||= {}
    end

    def register_value_transformer(options)
      type = options[:type]
      to = options[:to]
      from = options[:from]
      return if self.value_transformers.has_key? type
      self.value_transformers[type] = {to: to, from: from}
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
