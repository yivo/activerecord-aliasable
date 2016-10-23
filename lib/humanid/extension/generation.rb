# encoding: utf-8
# frozen_string_literal: true

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

        def ready_to_generate?(model)
          # Sometimes human id depends on record id or timestamps.
          # When record isn't persisted human id will be generated wrong.
          model.persisted?
        end
      end
    end
  end
end
