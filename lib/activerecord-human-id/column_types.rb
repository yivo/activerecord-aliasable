module HumanID
  module ColumnTypes
    def human_id(*args)
      options         = args.extract_options!
      options[:index] = options[:index] == false ?
        false :
        (options[:index] || {}).reverse_merge!(unique: true)
      args.each { |name| column(name, :string, options) }
    end

    # Commonly used
    def alias(*args)
      args << :alias if args.empty? || args.first.kind_of?(Hash)
      human_id(*args)
    end
  end
end