class ActiveRecord::ConnectionAdapters::TableDefinition
  def alias(*args)
    options      = { null: false, default: '', index: {unique: true} }.merge!(args.extract_options!)
    column_names = args.presence || [:alias]
    column_names.each { |name| column(name, :string, options) }
  end

  alias human_id alias
end