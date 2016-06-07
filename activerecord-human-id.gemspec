# frozen_string_literal: true
# encoding: utf-8
Gem::Specification.new do |s|
  s.name            = 'activerecord-human-id'
  s.version         = '1.0.0'
  s.authors         = ['Yaroslav Konoplov']
  s.email           = ['yaroslav@inbox.com']
  s.summary         = 'ActiveRecord human id'
  s.description     = 'ActiveRecord human id'
  s.homepage        = 'http://github.com/yivo/activerecord-human-id'
  s.license         = 'MIT'

  s.executables     = `git ls-files -z -- bin/*`.split("\x0").map{ |f| File.basename(f) }
  s.files           = `git ls-files -z`.split("\x0")
  s.test_files      = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  s.require_paths   = ['lib']

  s.add_dependency 'activesupport', '>= 3.2.0'
  s.add_dependency 'activerecord', '>= 3.0'
  s.add_dependency 'rails-i18n', '~> 4.0'
  s.add_dependency 'activerecord-traits', '~> 1.0.0'
  s.add_dependency 'unicode-tools', '~> 1.0.0'
end
