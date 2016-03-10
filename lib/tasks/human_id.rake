task 'human_id:regenerate' => :environment do
  force = [ENV['force'], ENV['FORCE']].include?('true')

  puts "Force #{force ? 'true' : 'false'}"

  Traits.each do |traits|
    attributes = traits.attributes.select do |attr|
      human_id = attr.features.human_id
      human_id && human_id.persists? && human_id.updates_automatically?
    end

    next if attributes.empty?

    traits.model_class.find_each do |model|
      puts "Processing #{traits.class_name}##{traits.primary_key_attribute.value_from(model)}"
      changes = 0
      attributes.each do |attr|
        current = attr.value_from(model)

        next if !force && !model.send("need_to_update_#{attr.name}?")

        new = model.send("generate_#{attr.name}")

        if current != new
          changes += 1
          puts "Current #{attr.name}: #{current ? "'#{current}'" : 'nil'}"
          puts "New #{attr.name}:     #{new     ? "'#{new}'"     : 'nil'}"

          model.send("assign_#{attr.name}")
        else
          puts "#{attr.name} didn't change"
        end

        puts
      end
      model.save! if changes > 0
    end
  end
end