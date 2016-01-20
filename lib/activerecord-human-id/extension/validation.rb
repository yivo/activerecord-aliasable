module HumanID
  module Extension
    module Validation
      class << self
        def validate_format_of(human_id, model)
          value   = model.send(human_id)
          options = model.send("options_for_#{human_id}")
          valid   = if options[:transliterate]
            HumanID::Transliteration.valid?(value)
          else
            HumanID::Canonicalization.valid?(value)
          end

          model.errors.add(human_id, :invalid) unless valid
          valid
        end
      end
    end
  end
end