require 'spec_helper'

describe Av::Commands::Ffmpeg do
  let(:subject) { Av::Commands::Ffmpeg.new }
  let(:list) { ['one', 'two'] }
  
  describe '.input_concat' do
    before do
      subject.input_concat(list)
    end
    
    it { expect(subject.input_params.first).to include %Q(concat -i) }
  end
end