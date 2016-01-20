module HumanID
  module Extension
    class Builder
      def initialize(model_class, options)
        @model                  = model_class
        @param                  = options[:param]
        @save                   = options[:save]
        @validations            = options[:validations]
        @format_validation      = @validations[:format]
        @uniqueness_validation  = @validations[:uniqueness]
      end

      def build(human_id)
        @human_id = human_id

        define_base_methods

        if @save
          define_persistence_methods
          add_persistence_callbacks
        else
          define_human_id_accessor
        end

        add_format_validation     if @format_validation
        add_uniqueness_validation if @uniqueness_validation

        define_to_param_method if @param
      end

    protected
      def define_base_methods
        @model.class_eval <<-BODY, __FILE__, __LINE__ + 1
          def generate_#{@human_id}
            HumanID::Extension::Generation.generate(:#{@human_id}, self)
          end

          def options_for_#{@human_id}
            human_id_options.fetch(:#{@human_id})
          end
        BODY
      end

      def define_persistence_methods
        @model.class_eval <<-BODY, __FILE__, __LINE__ + 1
          def need_to_assign_#{@human_id}?
            HumanID::Extension::Persistence.need_to_assign?(:#{@human_id}, self)
          end

          def assign_#{@human_id}!
            HumanID::Extension::Persistence.assign!(:#{@human_id}, self)
            nil
          end

          def assign_#{@human_id}
            HumanID::Extension::Persistence.assign(:#{@human_id}, self)
            nil
          end
        BODY
      end

      def define_human_id_accessor
        @model.class_eval <<-BODY, __FILE__, __LINE__ + 1
          def #{@human_id}
            @#{@human_id} ||= generate_#{@human_id}
          end
        BODY
      end

      def define_to_param_method
        @model.class_eval <<-BODY, __FILE__, __LINE__ + 1
          def to_param
            self.#{@human_id}
          end
        BODY
      end

      def add_persistence_callbacks
        @model.before_validation :"assign_#{@human_id}",  if: :"need_to_assign_#{@human_id}?"
        @model.after_save        :"assign_#{@human_id}!", if: :"need_to_assign_#{@human_id}?"
      end

      def add_uniqueness_validation
        @model.validates_uniqueness_of @human_id, case_sensitive: false, allow_blank: true
      end

      def add_format_validation
        @model.validate "format_of_#{@human_id}", if: "#{@human_id}?"

        @model.class_eval <<-BODY, __FILE__, __LINE__ + 1
          def format_of_#{@human_id}
            HumanID::Extension::Validation.validate_format_of(:#{@human_id}, self)
          end
        BODY
      end
    end
  end
end