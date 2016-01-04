module Essay
  class ModelFeatures
    def aliasable?
      model_class.attributes_marked_as_alias.any?
    end

    serialize do
      { is_aliasable: aliasable? }
    end
  end
  class AttributeFeatures
    def alias?
      model_class.attributes_marked_as_alias.include?(attribute_name)
    end

    serialize do
      { is_alias: alias? }
    end

    alias human_id? alias?
  end
end