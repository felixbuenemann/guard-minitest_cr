require 'guard/minitest_cr/inspector'
require 'English'

module Guard
  class MinitestCr < Plugin
    class Runner
      attr_accessor :inspector

      def initialize(options = {})
        @options = {
          all_after_pass:     false,
          all_env:            {},
          env:                {},
          test_folders:       %w(test spec),
          test_file_patterns: %w(*_test.cr test_*.cr *_spec.cr),
          test_helpers:       %w(test_helper.cr spec_helper.cr),
          cli:                nil
        }.merge(options)

        [:test_folders, :test_file_patterns, :test_helpers].each do |k|
          @options[k] = Array(@options[k]).uniq.compact
        end

        @inspector = Inspector.new(test_folders, test_file_patterns, test_helpers)
      end

      def run(paths, options = {})
        return unless options[:all] || !paths.empty?

        message = "Running: #{options[:all] ? 'all tests' : paths.join(' ')}"
        Compat::UI.info message, reset: true

        begin
          status = _run(*minitest_command(paths, options[:all]))
        rescue Errno::ENOENT => e
          Compat::UI.error e.message
          throw :task_has_failed
        end

        success = status.zero?

        Compat::UI.notify(message, title: 'Minitest results', image: success ? :success : :failed)

        run_all_coz_ok = @options[:all_after_pass] && success && !options[:all]
        run_all_coz_ok ?  run_all : success
      end

      def run_all
        paths = inspector.clean_all
        run(paths, all: true)
      end

      def run_on_modifications(paths = [])
        paths = inspector.clean(paths)
        run(paths, all: all_paths?(paths))
      end

      def run_on_additions(_paths)
        inspector.clear_memoized_test_files
        true
      end

      def run_on_removals(_paths)
        inspector.clear_memoized_test_files
      end

      private

      def cli_options
        @cli_options ||= Array(@options[:cli])
      end

      def all_after_pass?
        @options[:all_after_pass]
      end

      def test_folders
        @options[:test_folders]
      end

      def test_file_patterns
        @options[:test_file_patterns]
      end

      def test_helpers
        @options[:test_helpers]
      end

      def _run(*args)
        Compat::UI.debug "Running: #{args.join(' ')}"
        return $CHILD_STATUS.exitstatus unless Kernel.system(*args).nil?

        fail Errno::ENOENT, args.join(' ')
      end

      def minitest_command(paths, all)
        cmd_parts = []

        cmd_parts << crystal_command(paths)

        [cmd_parts.compact.join(' ')].tap do |args|
          env = generate_env(all)
          args.unshift(env) if env.length > 0
        end
      end

      def crystal_command(paths)
        cmd_parts  = ['crystal', 'run']
        cmd_parts.concat(paths)

        cmd_parts << '--'
        cmd_parts += cli_options
        cmd_parts
      end

      def generate_env(all = false)
        base_env.merge(all ? all_env : {})
      end

      def base_env
        Hash[(@options[:env] || {}).map { |key, value| [key.to_s, value.to_s] }]
      end

      def all_env
        return { @options[:all_env].to_s => 'true' } unless @options[:all_env].is_a? Hash
        Hash[@options[:all_env].map { |key, value| [key.to_s, value.to_s] }]
      end

      def all_paths?(paths)
        paths == inspector.all_test_files
      end

    end
  end
end
