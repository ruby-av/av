require 'spec_helper'

describe Av::Commands::Avconv do
  let(:subject) { Av::Commands::Avconv.new }
  let(:list) { ['one', 'two'] }
  
  describe '.input_concat' do
    before do
      subject.input_concat(list)
    end
    
    it { expect(subject.input_params.first).to include %Q(concat:one\\|two) }
  end
end

