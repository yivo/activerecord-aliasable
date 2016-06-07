# frozen_string_literal: true
class Essay::AttributeFeatures
  def human_id?
    model_class.attributes_marked_as_human_id.include?(attribute_name)
  end

  def human_id
    @human_id || @human_id = HumanID.new(env) if human_id?
  end

  serialize do
    {
      is_human_id: human_id?,
      human_id:    human_id.try(:to_hash)
    }
  end

  class HumanID < Base
    def persists?
      !!options[:persist]
    end

    def updates_manually?
      options[:update] == :manual
    end

    def updates_automatically?
      !updates_manually?
    end

    def updates_if_blank?
      options[:update] == :if_blank
    end

    def options
      model_class.human_id_options.fetch(attribute_name)
    end
  end
end
