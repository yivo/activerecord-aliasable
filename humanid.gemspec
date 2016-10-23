# encoding: utf-8
# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name            = 'humanid'
  s.version         = '1.0.1'
  s.authors         = ['Yaroslav Konoplov']
  s.email           = ['eahome00@gmail.com']
  s.summary         = 'ActiveRecord human id'
  s.description     = 'ActiveRecord human id'
  s.homepage        = 'http://github.com/yivo/activerecord-human-id'
  s.license         = 'MIT'

  s.executables     = `git ls-files -z -- bin/*`.split("\x0").map{ |f| File.basename(f) }
  s.files           = `git ls-files -z`.split("\x0")
  s.test_files      = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  s.require_paths   = ['lib']

  s.add_dependency 'activesupport',       '>= 3.0', '< 6.0'
  s.add_dependency 'activerecord',        '>= 3.0', '< 6.0'
  s.add_dependency 'activerecord-traits', '~> 1.1'
  s.add_dependency 'unicode-tools',       '~> 1.0'
  s.add_dependency 'rails-i18n'
end
