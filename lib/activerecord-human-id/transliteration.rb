module HumanID
  module Transliteration
    class << self
      #
      # HumanID::Transliteration.perform('Well-known English writer')
      #   => 'Well-known English writer'
      #
      # HumanID::Transliteration.perform('Пушкин, Александр Сергеевич')
      #   => 'Pushkin, Aleksandr Sergeevich'
      #
      # HumanID::Transliteration.perform('Пушкин, Александр Сергеевич', normalize: true)
      #   => 'Pushkin-Aleksandr-Sergeevich'
      #
      def perform(str, options = {})
        previous_locale = I18n.locale
        I18n.locale     = I18n.default_locale

        str = I18n.transliterate(str)

        str.downcase! if options.fetch(:downcase, false)

        if options.fetch(:normalize, false)
          # Strip leading and trailing non-word and non-ASCII characters
          str.gsub!(/(\A\W+)|(\W+\z)/, '')

          # Replace the rest of non-word and non-ASCII characters with hyphen
          str.gsub!(/\W+/, separator)
        end

        str
      ensure
        I18n.default_locale = previous_locale
      end

      attr_accessor :validation_regex

      # Not starts with hyphen
      # Contains 1 to 255 word characters and hyphens
      # Not ends with hyphen
      def valid?(human_id)
        human_id = human_id.to_s if human_id.kind_of?(Symbol)
        human_id.kind_of?(String) && !!(human_id =~ validation_regex)
      end

      def validate!(human_id)
        raise MalformedHumanIDError unless valid?(human_id)
        true
      end

      attr_accessor :separator
    end

    class MalformedHumanIDError < StandardError
      def initialize
        super 'Human ID is malformed'
      end
    end

    self.separator = '-'
    self.validation_regex = /(?!-)\A[\w-]{1,255}(?<!-)\z/
  end

  class << self
    def transliterate(str, options = {})
      Transliteration.perform(str, options)
    end
  end
end