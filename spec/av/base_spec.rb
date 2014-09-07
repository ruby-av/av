require 'spec_helper'

describe Av::Commands::Base do
  let(:subject) { Av.cli }
  let(:source) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4').path }
  
  describe '.identify' do
    let(:meta) { subject.identify source }
    
    it { expect(meta).to be_a Hash }
    it { expect(meta.keys).to include :size, :fps, :length, :aspect }
  end
end

