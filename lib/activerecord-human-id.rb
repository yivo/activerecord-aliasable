require 'active_support/all'
require 'active_record'
require 'rails-i18n'
require 'activerecord-traits'
require 'unicode-tools'

require 'activerecord-human-id/canonicalization'
require 'activerecord-human-id/transliteration'

require 'activerecord-human-id/extension'
require 'activerecord-human-id/extension/configuration'
require 'activerecord-human-id/extension/builder'
require 'activerecord-human-id/extension/pattern'
require 'activerecord-human-id/extension/persistence'
require 'activerecord-human-id/extension/generation'
require 'activerecord-human-id/extension/validation'

require 'activerecord-human-id/column_types'
require 'activerecord-human-id/essay' if defined?(Essay)

require 'activerecord-human-id/engine'

module ActiveRecord
  Base.include HumanID::Extension
  ConnectionAdapters::TableDefinition.include HumanID::ColumnTypes
end