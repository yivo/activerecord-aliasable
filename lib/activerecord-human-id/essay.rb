module Essay
  class AttributeFeatures
    def human_id?
      model_class.attributes_marked_as_human_id.include?(attribute_name)
    end

    serialize do
      { is_human_id: human_id? }
    end
  end
end