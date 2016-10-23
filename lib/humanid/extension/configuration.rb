# encoding: utf-8
# frozen_string_literal: true

module HumanID
  module Extension
    class << self
      attr_accessor :default_options
    end

    self.default_options = {

      # By default pattern will be guessed by steps:
      #   - try first attribute with string type
      #   - or try primary key attribute
      #   - or at worst: first attribute
      #
      # See HumanID::Extension::PatternHelper.guess.
      pattern: nil,

      # If set to true:           all available validations will be added.
      # If set to false:          no validations will be added.
      # If set to hash or array:  you choose what validations you need:
      #   => { format: true, uniqueness: false }
      #   => [:uniqueness]
      validations: { format: true, uniqueness: true },

      # This option determines whether `to_param` method will be defined.
      # See http://apidock.com/rails/ActiveRecord/Integration/ClassMethods/to_param
      param: false,

      # Chose what engine should be used to perform human id generation.
      engine: :transliteration,

      # If you want your human id to be persisted in database set this to true.
      persist: true,

      # This option determines whether human id will be updated.
      # Possible values:
      #   1. :if_blank  - human id will be updated only if it's value is blank;
      #   2. :always    - human id will be updated on each save regardless of the value;
      #   3. :manual    - human id will never be updated automatically.
      update: :if_blank
    }
  end
end
