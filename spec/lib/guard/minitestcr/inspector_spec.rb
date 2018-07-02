require 'guard/minitestcr/inspector'

RSpec.describe Guard::MinitestCr::Inspector do
  let(:inspector) { Guard::MinitestCr::Inspector.new(%w(test spec), %w(*_test.rb test_*.rb *_spec.rb), %w(test_helper.rb spec_helper.rb)) }

  describe 'clean' do
    before do
      @files_on_disk = Dir['spec/**/*_spec.rb'].sort
    end

    it 'should add all test files under the given dir' do
      expect(inspector.clean(['spec']).sort).to eq @files_on_disk
    end

    it 'should remove non-test files' do
      expect(inspector.clean(['spec/lib/guard/minitest_cr_spec.rb', 'bob.rb'])).to_not include 'bob.rb'
    end

    it 'should remove non-existing test files' do
      expect(inspector.clean(['spec/lib/guard/minitest_cr_spec.rb', 'bob_spec.rb'])).to_not include 'bob_spec.rb'
    end

    it 'should remove non-existing test files (2)' do
      expect(inspector.clean(['spec/lib/guard/minitest_cr/formatter_spec.rb'])).to eq []
    end

    it 'should keep test folder path' do
      expect(inspector.clean(['spec/lib/guard/minitest_cr_spec.rb', 'spec']).sort).to eq @files_on_disk
    end

    it 'should remove duplication' do
      expect(inspector.clean(['spec/lib/guard/minitest_cr_spec.rb', 'spec/lib/guard/minitest_cr_spec.rb'])).to eq ['spec/lib/guard/minitest_cr_spec.rb']
    end

    it 'should remove duplication (2)' do
      expect(inspector.clean(%w(spec spec)).sort).to eq @files_on_disk
    end

    it 'should remove test folder includes in other test folder' do
      expect(inspector.clean(['spec/minitest_cr', 'spec']).sort).to eq @files_on_disk
    end

    it 'should not include test files not in the given dir' do
      expect(inspector.clean(['spec/guard/minitest_cr'])).to_not include 'spec/guard/minitest_cr_spec.rb'
    end

    it 'should include test files in the root dir' do
      inspector = Guard::MinitestCr::Inspector.new(%w[.], %w[*.md], %w[CHANGELOG.md])
      expect(inspector.clean(['README.md'])).to eq ['README.md']
    end

    it 'should remove test helper files' do
      inspector = Guard::MinitestCr::Inspector.new(%w(spec), %w(spec_*.rb), %w(spec_helper.rb))
      expect(inspector.clean(['spec/spec_helper.rb'])).to eq []
    end
  end
end
