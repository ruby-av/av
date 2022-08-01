# frozen_string_literal: true

require 'spec_helper'

describe Av do
  it { expect(Av.cli).to be_kind_of Av::Cli }
  it { expect(Av.cli).not_to eq Av.cli }
  it { expect { Av.cli.run }.to raise_error Av::CommandError }

  describe 'run' do
    let(:subject) { Av.cli({ log: false, quiet: true }) }
    let(:source) { File.new("#{Dir.pwd}/spec/support/assets/sample.mp4").path }
    let(:destination) { "#{Dir.tmpdir}/test.mp4" }

    before do
      subject.add_source File.new("#{Dir.pwd}/spec/support/assets/sample.mp4")
    end

    describe 'with a valid output file' do
      before do
        subject.add_source source
        subject.add_destination destination
        subject.run
      end

      it { expect(File.exist?(destination)).to eq true }
    end
  end
end
