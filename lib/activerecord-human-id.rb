require 'active_support/all'
require 'active_record'
require 'rails-i18n'
require 'activerecord-traits'

require 'activerecord-human-id/extension'
require 'activerecord-human-id/column_types'
require 'activerecord-human-id/essay' if defined?(Essay)

module HumanID
  class << self
    attr_accessor :default_options, :regex
  end

  self.default_options = {

    # If set to true:  all available validations will be created
    # If set to false: no validations will be created
    # If set to hash:  you chose what validations you need
    #   => { format: true, uniqueness: false }
    validations: true,

    # If set to true:  callback for generating human id will be added
    # If set to false: callback for generating human id will not be added
    generate: true,

    # If set to true:  human id will be refreshed on each save
    # If set to false: human id will be refreshed only when it's value is blank
    refresh: false,

    # By default format will be guessed from:
    #   - first attribute of string type
    #   - primary key attribute
    #   - first available attribute
    #
    # For available values see HumanID.parse_format
    format: -> (model) do
      attrs = Traits.for(model).attributes
      attrs.first_where(type: :string).try(:name) ||
        attrs.first_where(primary_key?: true).try(:name) ||
        attrs.first.try(:name)
    end
  }

  # Not starts with hyphen
  # Contains 1 to 255 word characters and hyphens
  # Not ends with hyphen
  self.regex = /(?!-)\A[[:word:]-]{1,255}(?<!-)\z/

  class << self
    def transliterate(str)
      str = str.join('-') if str.is_a?(Array)

      str = I18n.transliterate(str)
      str.downcase!

      # Strip leading and trailing non-word characters
      str.gsub!(/(\A\W+)|(\W+\z)/, '')

      # Replace the rest of non-word characters with hyphen
      str.gsub!(/\W+/, '-')

      str
    end

    # TODO Think about name
    def normalize(str)
      str = str.join('-') if str.is_a?(Array)

      str = str.mb_chars.downcase.to_s

      # Strip leading and trailing non-word characters
      str.gsub!(/(\A[^[:word:]]+)|([^[:word:]]+\z)/, '')

      # Replace the rest of non-word characters with hyphen
      str.gsub!(/[^[:word:]]+/, '-')

      str
    end

    alias generate normalize

    def valid?(human_id)
      human_id = human_id.to_s if human_id.kind_of?(Symbol)
      human_id.kind_of?(String) && !!(human_id =~ regex)
    end

    def validate!(human_id)
      # TODO Error
      raise 'Human id is invalid' unless valid?(human_id)
      true
    end

    def source_for(human_id_attr, model)
      previous_locale = I18n.locale
      I18n.locale     = I18n.default_locale
      options         = options_for(human_id_attr, model.class)
      parse_format(options[:format], model)
    ensure
      I18n.locale = previous_locale
    end

    def options_for(human_id_attr, model_class)
      model_class.human_id_options.fetch(human_id_attr)
    end

  protected
    def parse_format(format, model)
      case format
        # format: -> (article) { "Article #{article.name}. Published at #{article.published_at.strftime('%d %B %Y')}" }
        when Proc   then parse_format(format.call(model), model)

        # format: ['Article', :name] => ['Article', 'Falling oil prices: Who are the winners and losers?']
        when Array  then format.map { |el| el.kind_of?(Symbol) ? model.send(el) : el }

        # format: :name
        when Symbol then model.send(format)

        # format: 'article-:id'
        else format.gsub(/:(\w+)/) { model.send($1) }
      end
    end
  end
end

module ActiveRecord
  Base.include HumanID::Extension
  ConnectionAdapters::TableDefinition.include HumanID::ColumnTypes
end