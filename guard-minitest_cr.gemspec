# encoding: utf-8

$:.push File.expand_path('../lib', __FILE__)
require 'guard/minitest_cr/version'

Gem::Specification.new do |s|
  s.name        = 'guard-minitest_cr'
  s.version     = Guard::MinitestCrVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Felix Bünemann', 'Yann Lugrin', 'Rémy Coutable']
  s.email       = ['felix.buenemann@gmail.com']
  s.homepage    = 'https://github.com/felixbuenemann/guard-minitest_cr'
  s.summary     = 'Guard plugin for the Crystal Minitest.cr framework'
  s.description = 'Guard::Minitest automatically run your tests with Minitest.cr framework (much like autotest)'

  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'guard', '>= 2.0.0'
  s.add_runtime_dependency 'guard-compat', '~> 1.2'

  s.add_development_dependency 'bundler'

  s.files        = `git ls-files -z lib`.split("\x0") + %w[CHANGELOG.md LICENSE README.md]
  s.require_path = 'lib'
end
