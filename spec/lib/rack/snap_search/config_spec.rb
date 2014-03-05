require 'spec_helper'

describe Rack::SnapSearch::Config do
    
    subject { described_class.new }
    
    let(:proc) do
        Proc.new {}
    end
    
    context 'For each attribute' do
        
        described_class::ATTRIBUTES.each do |attribute|
            it { should respond_to(attribute) } # Have a getter method
            it { should respond_to("#{attribute}=") } # Have a setter method
        end
        
    end
    
    describe '#on_exception' do
        
        it { should respond_to(:on_exception) }
        
        it 'should be a setter if a block is given and a getter if not' do
            subject.on_exception.should == nil
            subject.on_exception(&proc) # Note that this is the same as giving a block with do/end or curly brackets
            subject.on_exception.should == proc
        end
        
    end
    
    describe '#before_intercept' do
        
        it { should respond_to(:before_intercept) }
        
        it 'should be a setter if a block is given and a getter if not' do
            subject.before_intercept.should == nil
            subject.before_intercept(&proc) # Note that this is the same as giving a block with do/end or curly brackets
            subject.before_intercept.should == proc
        end
        
    end
    
    describe '#after_intercept' do
        
        it { should respond_to(:after_intercept) }
        
        it 'should be a setter if a block is given and a getter if not' do
            subject.after_intercept.should == nil
            subject.after_intercept(&proc) # Note that this is the same as giving a block with do/end or curly brackets
            subject.after_intercept.should == proc
        end
        
    end
    
end
