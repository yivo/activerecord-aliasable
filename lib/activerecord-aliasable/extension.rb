module Aliasable
  module Extension
    extend ActiveSupport::Concern

    included do
      class_attribute :aliasable_options,           instance_accessor: false, instance_predicate: false
      class_attribute :attributes_marked_as_alias,  instance_accessor: false, instance_predicate: false

      self.aliasable_options          = {}
      self.attributes_marked_as_alias = []
    end

    module ClassMethods

      # TODO Move this to different gem
      def generate_alias(text, limit = 255)
        text = text.join('-') if text.is_a?(Array)
        I18n.transliterate(text[0...limit]).downcase.gsub(/[\W_]+/, '-').gsub(/\A\W+/, '').gsub(/\W+\z/, '')
      end

      def aliasable(*args)
        args.unshift(:alias) if args.empty? || (args.size == 1 && args.last.kind_of?(Hash))
        alias_attr(*args)
      end

      def alias_attr(*attr_names)
        options = attr_names.extract_options!
        options.reverse_merge!(
          generate:          true,
          unique:            true,
          default:           false,
          include_id:        false,
          always_regenerate: false,
          from:              defined?(Traits) ?
                               traits.attributes.first_where(type: :string).try(:name) : nil
        )

        attr_names.each do |attr_name|
          attr_name = attr_name.to_sym

          attr_default attr_name, options[:default] if options[:default] != false

          if options[:generate]
            after_save :"assign_#{attr_name}!", if: :"should_regenerate_#{attr_name}?"
          end

          if options[:generate] && options[:unique]
            validator_options = { case_sensitive: false, allow_empty: true }
            validates attr_name, uniqueness: validator_options, if: :"#{attr_name}_missing?"
          end

          class_eval <<-BODY, __FILE__, __LINE__ + 1
            def #{attr_name}_missing?
              self[:#{attr_name}].blank?
            end

            def options_for_#{attr_name}
              self.class.alias_attributes[:#{attr_name}]
            end
          BODY

          if options[:generate]
            class_eval <<-BODY, __FILE__, __LINE__ + 1
              def #{attr_name}
                #{attr_name}_missing? ? self[:#{attr_name}] = assign_#{attr_name} : self[:#{attr_name}]
              end

              def assign_#{attr_name}!
                new_value = self.class.generate_alias(parts_for_#{attr_name})
                if self[:#{attr_name}] != new_value
                  self[:#{attr_name}] = new_value
                  save!
                end
              end

              def assign_#{attr_name}
                self[:#{attr_name}] = self.class.generate_alias(parts_for_#{attr_name})
              end

              def parts_for_#{attr_name}
                previous_locale = I18n.locale
                I18n.locale     = I18n.default_locale
                options         = options_for_#{attr_name}
                from            = options[:from]

                case from
                  when Proc   then instance_eval(&from)
                  when Array  then from.map { |el| el.kind_of?(Symbol) ? self[el] : el }
                  when Symbol then self[from]
                  else from
                end
              ensure
                I18n.locale = previous_locale
              end

              def #{attr_name}_missing?
                self[:#{attr_name}].blank?
              end

              def should_regenerate_#{attr_name}?
                !!options_for_#{attr_name}[:always_regenerate] || #{attr_name}_missing?
              end
            BODY
          end
        end

        self.aliasable_options = self.aliasable_options.dup
        attr_names.each do |attr_name|
          attr_name = attr_name.to_sym
          self.aliasable_options[attr_name] = (self.aliasable_options[attr_name] || {}).merge!(options.deep_dup)
        end
        self.attributes_marked_as_alias += attr_names
      end
    end
  end
end