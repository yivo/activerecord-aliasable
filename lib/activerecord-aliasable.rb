require 'active_record'
require 'activerecord-aliasable/extension'
require 'activerecord-aliasable/migration'
require 'activerecord-aliasable/essay' if defined?(Essay)

ActiveRecord::Base.include(Aliasable::Extension)