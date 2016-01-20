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
    def permanent?
      !!options[:permanent]
    end

    def save?
      !!options[:save]
    end

    def options
      model_class.human_id_options.fetch(attribute_name)
    end
  end
end