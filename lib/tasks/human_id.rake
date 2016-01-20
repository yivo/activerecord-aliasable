task 'human_id:regenerate' => :environment do
  Traits.each do |traits|
    attributes = traits.attributes.select do |attr|
      attr.features.human_id? && attr.features.human_id.save?
    end

    next if attributes.empty?

    traits.model_class.find_each do |model|
      attributes.each do |attr|
        current = attr.value_from(model)

        next if current.present? && attr.features.human_id.permanent?

        new = model.send("generate_#{attr.name}")

        if current != new
          puts "#{traits.class_name}##{traits.primary_key_attribute.value_from(model)}"
          puts "Current #{attr.name}: #{current ? "'#{current}'" : 'nil'}"
          puts "New #{attr.name}:     #{new     ? "'#{new}'"     : 'nil'}"
          puts

          model.send("assign_#{attr.name}")
        end
      end
      model.save!
    end
  end
end