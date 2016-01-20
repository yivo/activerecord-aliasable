module HumanID
  module Extension
    module Generation
      class << self
        def generate(human_id, model)
          options = model.send("options_for_#{human_id}")
          pattern = options.fetch(:compiled_pattern)
          data    = HumanID::Extension::Pattern.result(pattern, model)

          if options[:transliterate]
            HumanID::Transliteration.perform(data)
          else
            HumanID::Canonicalization.perform(data)
          end
        end
      end
    end
  end
end