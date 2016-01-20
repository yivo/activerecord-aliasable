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
        separator = behaviour.separator

        str = str.join(separator) if str.is_a?(Array)

        # This doesn't require comments
        UnicodeTools.strip_bidi_override_chars!(str)

        # Replace all whitespace characters (including leading,
        # trailing and inner) with HumanID.separator
        UnicodeTools.replace_whitespace!(str, separator)

        # Strip leading and trailing separators
        str.gsub! surrounding_separators_regex, ''

        # Replace two or more separator sequence with one separator: '__' => '_'
        str.gsub! separator_sequence_regex, separator

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

      def behaviour
        Behaviour.instance
      end

      attr_accessor :surrounding_separators_regex, :separator_sequence_regex
    end

    class Behaviour
      include Singleton

      attr_accessor :separator

      def initialize
        self.separator = '_'
      end

      def separator=(new_sep)
        @separator = new_sep

        # Rebuild separator regexps
        HumanID::Canonicalization.surrounding_separators_regex = /(\A#{new_sep}+)|(#{new_sep}+\z)/
        HumanID::Canonicalization.separator_sequence_regex     = /#{new_sep}+/

        new_sep
      end
    end

    class MalformedHumanIDError < StandardError
      def initialize
        super 'Human ID is malformed'
      end
    end
  end

  class << self
    def canonicalize(str)
      Canonicalization.perform(str)
    end
  end
end