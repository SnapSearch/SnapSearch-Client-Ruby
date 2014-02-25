require 'spec_helper'
require 'rack/request'

describe 'Rack application QS splitting' do
    
    let(:env) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:25.0) Gecko/20100101 Firefox/25.0', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'REQUEST_SCHEME' => 'http', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => 'key%201=value+1&_escaped_fragment_=%2Fpath2%3Fkey2=value2',
            'PATH_INFO' => '/snapsearch/path1',
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    subject { Rack::Request.new(env) }
    
    it 'should decode the key/values when splitting the params of a request' do
      subject.params.should == {
        'key 1' => 'value 1',
        "_escaped_fragment_" => '/path2?key2=value2'
      }
    end
    
end
