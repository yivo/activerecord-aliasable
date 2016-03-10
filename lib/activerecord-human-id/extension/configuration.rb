module HumanID
  module Extension
    class << self
      attr_accessor :default_options
    end

    self.default_options = {

      # By default pattern will be guessed:
      #   - try first attribute with string type
      #   - or try primary key attribute
      #   - or at worst: first attribute
      #
      # See HumanID::Extension::PatternHelper.guess
      pattern: nil,

      # If set to true:           all available validations will be added
      # If set to false:          no validations will be added
      # If set to hash or array:  you chose what validations you need
      #   => { format: true, uniqueness: false }
      #   => [:uniqueness]
      validations: { format: true, uniqueness: true },

      # If set to true:  will define `to_param` method which returns human id value
      # If set to false: method will not be defined
      param: false,

      # Chose what engine should be used to perform human id generation
      engine: :transliteration,

      # If set to true:  human id will be refreshed on each save
      # If set to false: human id will be refreshed only when it's value is blank
      permanent: false,

      # TODO Write description
      save: true
    }
  end
end