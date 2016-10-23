# encoding: utf-8
# frozen_string_literal: true

module HumanID
  module Migration
    def human_id(*args)
      options         = args.extract_options!
      options[:index] = case options[:index]
        when true  then { unique: true }
        when false then false
        else            (options[:index] || {}).reverse_merge!(unique: true)
      end

      args.each { |name| column(name, :string, options) }
    end

    # Commonly used
    def alias(*args)
      args << :alias if args.empty? || args.first.kind_of?(Hash)
      human_id(*args)
    end
  end
end
