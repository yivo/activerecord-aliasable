module HumanID
  module Canonicalization
    class << self
      #
      # HumanID::Canonicalization.perform('Well-known English writer')
      #   => 'Well-known_English_writer'
      #
      # HumanID::Canonicalization.perform('Пушкин, Александр Сергеевич')
      #   => 'Пушкин,_Александр_Сергеевич'
      #
      def perform(str)
        str = str.join(separator) if str.is_a?(Array)

        # This doesn't require comments
        UnicodeTools.strip_bidi_override_chars!(str)

        # Replace all whitespace characters (including leading,
        # trailing and inner) with HumanID.separator
        UnicodeTools.replace_whitespace!(str, separator)

        # Strip leading and trailing separators
        str.gsub! @re_surrounding_separators, ''

        # Replace two or more separator sequence with one separator: '__' => '_'
        str.gsub! @re_separator_sequence, separator

        str
      end

      def valid?(human_id)
        human_id = human_id.to_s if human_id.kind_of?(Symbol)
        human_id.kind_of?(String) &&
          UnicodeTools.has_bidi_override?(human_id) == false &&
          UnicodeTools.has_whitespace?(human_id)    == false
      end

      def validate!(human_id)
        raise MalformedHumanIDError unless valid?(human_id)
        true
      end

      attr_accessor :separator

      def separator=(new_sep)
        @separator = new_sep

        # Rebuild separator regexps
        @re_surrounding_separators = /(\A#{new_sep}+)|(#{new_sep}+\z)/
        @re_separator_sequence     = /#{new_sep}+/

        new_sep
      end
    end

    class MalformedHumanIDError < StandardError
      def initialize
        super 'Human ID is malformed'
      end
    end

    self.separator = '_'
  end

  class << self
    def canonicalize(str)
      Canonicalization.perform(str)
    end
  end
end