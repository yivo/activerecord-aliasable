module HumanID
  module Extension
    extend ActiveSupport::Concern

    included do
      class_attribute :human_id_options,              instance_accessor: false, instance_predicate: false
      class_attribute :attributes_marked_as_human_id, instance_accessor: false, instance_predicate: false

      # Hash of options for each defined human id:
      #   => { alias: { generate: true, ... }, key: { generate: false, ... } }
      self.human_id_options              = {}

      self.attributes_marked_as_human_id = []
    end

    module ClassMethods
      def has_human_id(*args)
        options     = args.extract_options!.reverse_merge!(HumanID.default_options)
        generate    = options[:generate]
        validations = options[:validations]

        args.each do |attr_name|
          after_save :"assign_#{attr_name}!", if: :"refresh_#{attr_name}?" if generate != false

          if validations != false
            format     = !validations.is_a?(Hash) || validations[:format] != false
            uniqueness = !validations.is_a?(Hash) || validations[:uniqueness] != false

            validates_format_of attr_name, with: HumanID.regex, if: "#{attr_name}?" if format
            validates_uniqueness_of attr_name, case_sensitive: false,
                                               allow_empty: true,
                                               if: :"#{attr_name}?" if uniqueness
          end

          class_eval <<-BODY, __FILE__, __LINE__ + 1
            def generate_#{attr_name}
              HumanID.generate(source_for_#{attr_name})
            end

            def #{attr_name}
              assign_#{attr_name} unless #{attr_name}?
              super
            end

            def assign_#{attr_name}!
              # Sometimes human id depends on record id.
              # When record isn't persisted human id will be generated wrong.
              # Same approach in assign_#{attr_name}. See options
              if persisted?
                new_value = generate_#{attr_name}
                if self[:#{attr_name}] != new_value
                  self[:#{attr_name}] = new_value
                  save!
                end
              end
              nil
            end

            def assign_#{attr_name}
              if persisted?
                self[:#{attr_name}] = generate_#{attr_name}
              end
              nil
            end

            def source_for_#{attr_name}
              HumanID.source_for(:#{attr_name}, self)
            end

            def options_for_#{attr_name}
              HumanID.options_for(:#{attr_name}, self.class)
            end

            def refresh_#{attr_name}?
              options_for_#{attr_name}[:refresh] == true ||
                #{attr_name}? == false ||
                HumanID.valid?(self.#{attr_name}) == false
            end
          BODY
        end

        all_options = self.human_id_options = self.human_id_options.dup
        args.each do |attr_name|
          all_options[attr_name] = (all_options[attr_name] || {}).merge!(options.deep_dup)
        end

        self.attributes_marked_as_human_id += args
      end
    end
  end
end