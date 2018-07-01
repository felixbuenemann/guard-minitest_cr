# Guard::MinitestCr
[![Gem Version](https://badge.fury.io/rb/guard-minitest_cr.svg)](http://badge.fury.io/rb/guard-minitest_cr) [![Build Status](https://travis-ci.org/felixbuenemann/guard-minitest_cr.svg?branch=master)](https://travis-ci.org/felixbuenemann/guard-minitest_cr)

Guard::MinitestCr allows to automatically & intelligently launch tests with the Crystal
[minitest.cr framework](https://github.com/ysbaddaden/minitest.cr) when files are modified.

## Install

Please be sure to have [Guard](http://github.com/guard/guard) installed before you continue.

The simplest way to install Guard::MinitestCr is to use [Bundler](http://gembundler.com/).

Add Guard::MinitestCr to your `Gemfile`:

```ruby
group :development do
  gem 'guard-minitest_cr'
end
```

and install it by running Bundler:

```bash
$ bundle
```

Add guard definition to your Guardfile by running the following command:

```bash
guard init minitest_cr
```

## Usage

Please read [Guard usage doc](http://github.com/guard/guard#readme)

## Guardfile

Guard::MinitestCr can be adapated to all kind of projects.
Please read [guard doc](http://github.com/guard/guard#readme) for more info about the Guardfile DSL.

### Standard Guardfile when using Minitest::Test

```ruby
guard :minitest_cr do
  watch(%r{^test/(.+)_test\.cr$})
  watch(%r{^src/(.+)\.cr$})         { |m| "test/#{m[1]}_test.cr" }
  watch(%r{^test/test_helper\.cr$}) { Dir.glob("test/**/*_test.cr") }
end
```

### Standard Guardfile when using Minitest::Spec

```ruby
guard :minitest_cr do
  watch(%r{^spec/(.+)_spec\.cr$})
  watch(%r{^src/(.+)\.cr$})         { |m| "spec/#{m[1]}_spec.cr" }
  watch(%r{^spec/spec_helper\.cr$}) { Dir.glob("spec/**/*_spec.cr") }
end
```

## Options

### List of available options

```ruby
all_on_start: false               # run all tests in group on startup, default: true
all_after_pass: true              # run all tests in group after changed specs pass, default: false
cli: '--verbose'                  # pass arbitrary Minitest CLI arguments, default: ''
test_folders: ['tests']           # specify an array of paths that contain test files, default: %w[test spec]
test_file_patterns: %w[test_*.cr] # specify an array of patterns that test files must match in order to be run, default: %w[*_test.cr test_*.cr *_spec.cr]
test_helpers: ['test_helper.cr']  # specify an array of test helpers that should be excluded from test files, default: %w[test_helper.cr spec_helper.cr]
env: {}                           # specify some environment variables to be set when the test command is invoked, default: {}
all_env: {}                       # specify additional environment variables to be set when all tests are being run, default: false
```

### Options usage examples

#### `:test_folders` and `:test_file_patterns`

You can change the default location of test files using the `:test_folders` option and change the pattern of test files using the `:test_file_patterns` option:

```ruby
guard :minitest_cr, test_folders: 'test/unit', test_file_patterns: '*_test.rb' do
  # ...
end
```

#### `:cli`

You can pass any of the standard MiniTest CLI options using the `:cli` option:

```ruby
guard :minitest_cr, cli: '--seed 123456 --verbose' do
  # ...
end
```

## Development

* Documentation hosted at [RubyDoc](http://rubydoc.info/github/felixbuenemann/guard-minitest_cr/master/frames).
* Source hosted at [GitHub](https://github.com/felixbuenemann/guard-minitest_cr).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested. All specs run by Travis CI must pass.
* Update the [README](https://github.com/felixbuenemann/guard-minitest_cr/blob/master/README.md).
* Please **do not change** the version number.

For questions please join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

## Author

[Felix Bünemann](https://github.com/felixbuenemann)

This is a fork of the [guard-minitest](https://github.com/guard/guard-minitest) gem that was adapted to work with the minitest.cr Crystal Shard.

## Contributors

[https://github.com/felixbuenemann/guard-minitest\_cr/graphs/contributors](https://github.com/felixbuenemann/guard-minitest_cr/graphs/contributors)
