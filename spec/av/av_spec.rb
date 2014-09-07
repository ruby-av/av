require 'spec_helper'

describe Av do
  it { expect(Av.cli).to be_kind_of Av::Commands::Base }
  it { expect { Av.cli.run }.to raise_error Av::InvalidInputFile }
  
  describe 'run' do
    let(:subject) { Av.cli }
    let(:source) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4').path }
    let(:destination) { "#{Dir.tmpdir}/test.mp4" }
    
    before do
      subject.add_source File.new(Dir.pwd + '/spec/support/assets/sample.mp4')
    end
    describe 'with no output file' do
      it { expect {subject.run}.to raise_error Av::InvalidOutputFile }
    end
    
    describe 'with a valid output file' do
      before do
        subject.add_source source
        subject.add_destination destination
        subject.run
      end
      
      it { expect(File.exists?(destination)).to eq true }
    end
  end
end