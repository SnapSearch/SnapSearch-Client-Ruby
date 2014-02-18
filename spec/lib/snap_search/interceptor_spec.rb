require 'spec_helper'

describe SnapSearch::Interceptor do
    
    let(:detector) { double }
    let(:client) { double }
    
    before do
        detector.stub(:detect) { true }
        detector.stub(:get_encoded_url) { 'http://blah.com' }
        
        client.stub(:request) do
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
    end
    
    subject { described_class.new(client, detector) }
    
    it 'should be a Hash' do
        content = subject.intercept
        content.should be_a(Hash)
    end
    
end
