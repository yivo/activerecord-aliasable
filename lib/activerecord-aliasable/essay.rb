module Essay
  class ModelFeatures
    def aliasable?
      model_class.attributes_marked_as_alias.any?
    end
  end
  class AttributeRoles
    def alias?
      model_class.attributes_marked_as_alias.include?(attribute_name)
    end

    alias human_id? alias?

    def alias_part?

    end
  end
end