module HumanID
  module Extension
    module Generation
      class << self
        def generate(human_id, model)
          options = model.send("options_for_#{human_id}")
          pattern = options.fetch(:compiled_pattern)
          data    = HumanID::Extension::Pattern.result(pattern, model)
          HumanID.engine(options[:engine]).perform(data)
        end
      end
    end
  end
end