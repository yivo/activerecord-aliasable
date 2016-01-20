module HumanID
  module Extension
    module Persistence
      class << self
        def assign!(human_id, model)
          # Sometimes human id depends on record id or timestamps.
          # When record isn't persisted human id will be generated wrong.
          if model.persisted?
            new_value = model.send("generate_#{human_id}")
            if model.send(human_id) != new_value
              model.send("#{human_id}=", new_value)
              model.save!
            end
          end
        end

        def assign(human_id, model)
          # Sometimes human id depends on record id or timestamps.
          # When record isn't persisted human id will be generated wrong.
          if model.persisted?
            model.send("#{human_id}=", model.send("generate_#{human_id}"))
          end
        end

        def need_to_assign?(human_id, model)
          !model.send("options_for_#{human_id}")[:permanent] || !model.send("#{human_id}?")
        end
      end
    end
  end
end