# frozen_string_literal: true
module HumanID
  module Extension
    module Persistence
      class << self
        def assign!(human_id, model)
          if Generation.ready_to_generate?(model)
            new_value = model.send("generate_#{human_id}")
            if model.send(human_id) != new_value
              model[human_id] = new_value
              model.update_column(human_id, new_value)
              model.save!
            end
          end
        end

        def assign(human_id, model)
          # Sometimes human id depends on record id or timestamps.
          # When record isn't persisted human id will be generated wrong.
          if Generation.ready_to_generate?(model)
            model.send("#{human_id}=", model.send("generate_#{human_id}"))
          end
        end

        def need_to_update?(human_id, model)
          options = model.send("options_for_#{human_id}")
          case options[:update]
            when :always        then true
            when nil, :if_blank then !model.send("#{human_id}?")
                                else false
          end
        end
      end
    end
  end
end
