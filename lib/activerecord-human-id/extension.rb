module HumanID
  module Extension
    extend ActiveSupport::Concern

    included do
      class_attribute :human_id_options,
        instance_reader: true, instance_writer: false, instance_predicate: false

      class_attribute :attributes_marked_as_human_id,
        instance_accessor: false, instance_predicate: false

      # Hash of options for each defined human id:
      #   => { alias: { pattern: [:id, :name], ... }, key: { pattern: [:id, :name], ... } }
      self.human_id_options              = {}

      self.attributes_marked_as_human_id = []
    end

    module ClassMethods
      def has_human_id(*args)
        options = args.extract_options!.reverse_merge!(HumanID::Extension.default_options)

        pattern                    = options.delete(:pattern) || Pattern.guess(self)
        options[:original_pattern] = pattern
        options[:compiled_pattern] = Pattern.compile(pattern)

        val                   = options[:validations]
        options[:validations] = case val
          when Hash  then val.reverse_merge!(HumanID::Extension.default_options[:validations])
          when Array then %i( format uniqueness ).each_with_object({}) { |el, obj| obj[el] = val.include?(el) }
          else            { format: !!val, uniqueness: !!val }
        end

        builder = Builder.new(self, options)

        self.human_id_options = self.human_id_options.dup
        args.each do |attr_name|
          builder.build(attr_name)
          self.human_id_options[attr_name] = options.deep_dup
        end

        self.attributes_marked_as_human_id += args
      end
    end
  end
end