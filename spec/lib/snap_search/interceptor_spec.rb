require 'spec_helper'
require 'rack/request'

describe SnapSearch::Interceptor do
    
    let(:detector) { double }
    let(:client) { double }
    let(:mock_response) do
        {
            'status' => 200,
            'headers' => {
                'name' => 'Date',
                'value' => 'Tue, 19 Nov 2013 18:23:41 GMT'
            },
            'html' => '<html>Hi!</html>',
            'screenshot' => '',
            'date' => '324836'
        }
    end
    
    before do
        detector.stub(:detect) { true }
        detector.stub(:get_encoded_url) { 'http://blah.com' }
        
        client.stub(:request) { mock_response }
    end
    
    subject { described_class.new(client, detector) }
    
    let(:request) { Rack::Request.new( { 'rack.input' => StringIO.new }.merge(client.request) ) }
    
    it 'should be a Hash' do
        content = subject.intercept(request: request)
        
        content.should be_a(Hash)
    end
    
    describe 'callbacks' do
        
        describe '#before_intercept' do
            
            it 'should receive the current URL as a block argument' do
                before_intercept_url = ''
                
                subject.before_intercept { |url| before_intercept_url = url }
                
                subject.intercept(request: request)
                
                before_intercept_url.should == subject.encoded_url
            end
            
            it 'should respond with the result of the callback if a Hash is returned' do
                response_hash = { 'test' => 'value' }
                
                subject.before_intercept { response_hash }
                
                content = subject.intercept(request: request)
                
                content.should == response_hash
            end
            
            it 'should not respond with the result of the callback if a Hash is not returned' do
              response_string = 'i will not be the response!'
              
              subject.before_intercept { response_string }
              
              content = subject.intercept(request: request)
              
              content.should != response_string
            end
            
        end
        
        describe '#after_intercept' do
            
            it 'should receive the current URL and response Hash as a block argument' do
              after_intercept_url = ''
              after_intercept_response_hash = nil
              
              subject.after_intercept { |url, response| after_intercept_url, after_intercept_response_hash = url, response }
              
              content = subject.intercept(request: request)
              
              after_intercept_url.should == subject.encoded_url
              after_intercept_response_hash.should == content
              after_intercept_response_hash.should == mock_response
            end
            
            it 'should not need to accept block arguments' do
                after_intercept = nil
                
                subject.after_intercept { after_intercept = 'whateveriwant' }
                
                subject.intercept(request: request)
                
                after_intercept.should == 'whateveriwant'
            end
            
        end
        
        it 'should be able to be chained' do
            before_value, after_value = '', ''
            
            subject.
                before_intercept { before_value = 'success' }.
                after_intercept { after_value = 'success' }.
                intercept
            
            before_value.should == 'success'
            after_value.should == 'success'
        end
        
    end
    
end
