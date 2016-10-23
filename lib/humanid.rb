# encoding: utf-8
# frozen_string_literal: true

require 'active_support/all'
require 'active_record'
require 'rails-i18n'
require 'activerecord-traits'
require 'unicode-tools'

require 'humanid/canonicalization'
require 'humanid/transliteration'
require 'humanid/extension'
require 'humanid/extension/configuration'
require 'humanid/extension/builder'
require 'humanid/extension/pattern'
require 'humanid/extension/persistence'
require 'humanid/extension/generation'
require 'humanid/extension/validation'
require 'humanid/migration'
require 'humanid/railtie'

begin
  require 'essay'
  require 'humanid/essay'
rescue LoadError
end

module HumanID
  class << self
    def engine(engine = :transliteration)
      engine == :canonicalization ? Canonicalization : Transliteration
    end
  end
end

class ActiveRecord::Base
  include HumanID::Extension
end

class ActiveRecord::ConnectionAdapters::TableDefinition
  include HumanID::Migration
end
