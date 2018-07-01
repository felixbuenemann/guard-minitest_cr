source 'https://rubygems.org'

gemspec development_group: :gem_build_deps

group :gem_build_deps do
  gem 'rake'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'ruby_gntp', require: false

  gem 'guard-rubocop', require: false
end

group :test do
  gem 'rspec', '>= 3.1.0', require: false
end
