require 'active_support/all'
require 'active_record'
require 'rails-i18n'
require 'activerecord-traits'

require 'activerecord-aliasable/extension'
require 'activerecord-aliasable/migration'

require 'activerecord-aliasable/essay' if defined?(Essay)

ActiveRecord::Base.include(Aliasable::Extension)