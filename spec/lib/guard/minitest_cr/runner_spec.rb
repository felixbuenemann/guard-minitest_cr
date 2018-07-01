require 'guard/minitest_cr/runner'

RSpec.describe Guard::MinitestCr::Runner do
  let(:options) { {} }
  subject { described_class.new(options) }

  before do
    allow(Guard::Compat::UI).to receive(:notify)
    allow(Guard::Compat::UI).to receive(:debug)

    allow(Kernel).to receive(:system) do |*args|
      fail "stub me: Kernel.system(#{ args.map(&:inspect) * ', '})"
    end
  end

  describe 'options' do
    describe 'cli_options' do
      it 'defaults to empty string' do
        expect(subject.send(:cli_options)).to eq []
      end

      context 'with cli' do
        let(:options) { { cli: '--test' } }
        it 'is set with \'cli\'' do
          expect(subject.send(:cli_options)).to eq ['--test']
        end
      end
    end

    describe 'all_after_pass' do
      it 'defaults to false' do
        expect(subject.send(:all_after_pass?)).to eq false
      end

      context 'when true' do
        let(:options) { { all_after_pass: true } }
        specify { expect(subject.send(:all_after_pass?)).to eq true }
      end
    end
  end

  describe 'run' do
    before do
      allow(Dir).to receive(:pwd).and_return(fixtures_path.join('empty'))
    end

    context 'when Guard is in debug mode' do
      before do
        allow(Kernel).to receive(:system) { system('true') }
        allow(Guard::Compat::UI).to receive(:error)
      end

      it 'outputs command' do
        expect(Guard::Compat::UI).to receive(:debug).with("Running: crystal run test/test_minitest.cr --")
        subject.run(['test/test_minitest.cr'])
      end
    end

    context 'when binary is not found' do
      before do
        allow(Kernel).to receive(:system) { nil }
        allow(Guard::Compat::UI).to receive(:error)
      end

      it 'shows an error' do
        expect(Guard::Compat::UI).to receive(:error).with("No such file or directory - crystal run test/test_minitest.cr --")
        catch(:task_has_failed) { subject.run(['test/test_minitest.cr']) }
      end

      it 'throw a task_has_failed symbol' do
        expect { subject.run(['test/test_minitest.cr']) }.to throw_symbol(:task_has_failed)
      end
    end

    context 'with cli arguments' do
      let(:options) { { cli: '--seed 12345 --verbose' } }

      it 'passes :cli arguments' do
        expect(Kernel).to receive(:system).with(
          "crystal run test/test_minitest.cr -- --seed 12345 --verbose"
        ) { system('true') }

        subject.run(['test/test_minitest.cr'])
      end
    end

    context 'when running the full suite' do
      let(:options) { { all_env: { 'TESTS_ALL' => true } } }
      it 'sets env via all_env if running the full suite' do
        expect(Kernel).to receive(:system).with(
          { 'TESTS_ALL' => 'true' },
          "crystal run test/test_minitest.cr --"
        ) { system('true') }

        subject.run(['test/test_minitest.cr'], all: true)
      end
    end

    context 'allows string setting of all_env' do
      let(:options) { { all_env: 'TESTS_ALL' } }
      it 'allows string setting of all_env' do
        expect(Kernel).to receive(:system).with(
          { 'TESTS_ALL' => 'true' },
          "crystal run test/test_minitest.cr --"
        ) { system('true') }

        subject.run(['test/test_minitest.cr'], all: true)
      end
    end

    context 'runs with the specified environment' do
      let(:options) { { env: { MINITEST_TEST: 'test' } } }
      it 'runs with the specified environment' do
        expect(Kernel).to receive(:system).with(
          { 'MINITEST_TEST' => 'test' },
          "crystal run test/test_minitest.cr --"
        ) { system('true') }

        subject.run(['test/test_minitest.cr'])
      end
    end

    context 'with the all environment' do
      let(:options) { { env: { MINITEST_TEST: 'test', MINITEST: true }, all_env: { MINITEST_TEST: 'all' } } }
      it 'merges the specified environment' do
        expect(Kernel).to receive(:system).with(
          { 'MINITEST_TEST' => 'all', 'MINITEST' => 'true' },
          "crystal run test/test_minitest.cr --"
        ) { system('true') }

        subject.run(['test/test_minitest.cr'], all: true)
      end
    end

    describe 'all_after_pass' do
      describe 'when set' do
        let(:options) { { all_after_pass: true } }

        it 'runs all tests after success' do
          allow(Kernel).to receive(:system) { system('true') }
          expect(subject).to receive(:run_all)

          subject.run(['test/test_minitest.cr'])
        end

        it 'does not run all tests after failure' do
          allow(Kernel).to receive(:system) { system('false') }
          expect(subject).to receive(:run_all).never

          subject.run(['test/test_minitest.cr'])
        end
      end

      describe 'when unset' do
        let(:options) { { all_after_pass: false } }

        it 'does not run all tests again after success' do
          allow(Kernel).to receive(:system) { system('true') }
          expect(subject).to receive(:run_all).never

          subject.run(['test/test_minitest.cr'])
        end
      end
    end

    describe 'when no paths are passed' do
      it 'does not run a command' do
        expect(Kernel).to_not receive(:system)

        subject.run([])
      end

      it 'still runs all if requested' do
        expect(Kernel).to receive(:system)
          .with("crystal run --") { system('true') }

        expect(subject.run([], all: true)).to eq true
      end
    end
  end

  describe 'run_all' do
    it 'runs all tests' do
      paths = %w(test/test_minitest_1.cr test/test_minitest_2.cr)
      allow(subject.inspector).to receive(:clean_all).and_return(paths)
      expect(subject).to receive(:run).with(paths,  all: true).and_return(true)

      expect(subject.run_all).to eq true
    end
  end

  describe 'run_on_modifications' do
    before do
      @paths = %w(test/test_minitest_1.cr test/test_minitest_2.cr)
      allow(Dir).to receive(:pwd).and_return(fixtures_path.join('empty'))
      expect(Dir).to receive(:[]).and_return(@paths)
      expect(Dir).to receive(:[]).and_return([])
    end

    describe 'when all paths are passed' do
      before do
        allow(subject.inspector).to receive(:clean).and_return(@paths)
      end

      it 'runs minitest in all paths' do
        expect(subject).to receive(:run).with(@paths, all: true).and_return(true)

        expect(subject.run_on_modifications(@paths)).to eq true
      end

      context 'even when all_after_pass is enabled' do
        let(:options) { { all_after_pass: true } }
        it 'does not run all tests again after success' do
          allow(Kernel).to receive(:system) { system('true') }
          expect(subject).to receive(:run_all).never

          expect(subject.run_on_modifications(@paths)).to eq true
        end
      end
    end

    describe 'when not all paths are passed' do
      before do
        allow(subject.inspector).to receive(:clean).and_return(['test/test_minitest_1.cr'])
      end

      it 'runs minitest in paths' do
        expect(subject).to receive(:run).with(['test/test_minitest_1.cr'], all: false).and_return(true)

        expect(subject.run_on_modifications(@paths)).to eq true
      end

      context 'with all_after_pass enabled' do
        let(:options) { { all_after_pass: true } }

        before do
          allow(subject.inspector).to receive(:clean_all).and_return(
            ['test/test_minitest_1.cr', 'test/test_minitest_2.cr']
          )
        end

        it 'runs all tests again after success if all_after_pass enabled' do
          subject
          allow(Kernel).to receive(:system) { system('true') }
          allow(subject).to receive(:run).with(['test/test_minitest_1.cr'], all: false).and_call_original
          expect(subject).to receive(:run).with(@paths, all: true).and_return(true)

          expect(subject.run_on_modifications(@paths)).to eq true
        end
      end
    end
  end

  describe 'run_on_additions' do
    it 'clears the test file cache and runs minitest for the new path' do
      allow(subject.inspector).to receive(:clean).with(['test/guard/minitest/test_new.cr']).and_return(['test/guard/minitest/test_new.cr'])
      expect(subject.inspector).to receive(:clear_memoized_test_files)

      expect(subject.run_on_additions(['test/guard/minitest/test_new.cr'])).to eq true
    end
  end

  describe 'run_on_removals' do
    it 'clears the test file cache and does not run minitest' do
      allow(subject.inspector).to receive(:clean).with(['test/guard/minitest/test_deleted.cr']).and_return(['test/guard/minitest/test_deleted.cr'])
      expect(subject.inspector).to receive(:clear_memoized_test_files)
      expect(subject).to receive(:run).never

      subject.run_on_removals(['test/guard/minitest/test_deleted.cr'])
    end
  end

  context 'when guard is not included' do
    before do
      allow(Kernel).to receive(:system).and_call_original
    end

    it 'loads correctly as minitest plugin' do
      code = <<-EOS
        require 'guard/minitest_cr/runner'
      EOS

      system(*%w(bundle exec ruby -e) + [code])
    end
  end
end
