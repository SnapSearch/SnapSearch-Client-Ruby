require 'spec_helper'
require 'rack/request'

describe SnapSearch::Detector do
    
    let(:normal_browser) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:25.0) Gecko/20100101 Firefox/25.0', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/',
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:search_engine) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'AdsBot-Google ( http://www.google.com/adsbot.html)', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/',
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:snapsearch_robot) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'SnapSearch', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/',
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:non_get_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'AdsBot-Google ( http://www.google.com/adsbot.html)',
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'POST', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
        
    let(:ignored_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'Googlebot-Video/1.0', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/ignored/', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:matched_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'msnbot/1.1 ( http://search.msn.com/msnbot.htm)', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'REQUEST_SCHEME' => 'http', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/matched/', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:basic_escaped_fragment_route) do
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
            'QUERY_STRING' => '_escaped_fragment_',
            'PATH_INFO' => '/snapsearch',
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:escaped_fragment_route) do
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
            'QUERY_STRING' => 'key1=value1&_escaped_fragment_=%2Fpath2%3Fkey2=value2',
            'PATH_INFO' => '/snapsearch/path1',
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:valid_file_extension_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'AdsBot-Google ( http://www.google.com/adsbot.html)', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'REQUEST_SCHEME' => 'http', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/song.html?key=value', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:invalid_file_extension_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'AdsBot-Google ( http://www.google.com/adsbot.html)', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'REQUEST_SCHEME' => 'http', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/song.html.mp3?key=value', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:nonexistent_file_extension_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'AdsBot-Google ( http://www.google.com/adsbot.html)', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'REQUEST_SCHEME' => 'http', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    let(:mp3_file_extension_route) do
        {
            'HTTP_HOST' => 'localhost', 
            'HTTP_USER_AGENT' => 'AdsBot-Google ( http://www.google.com/adsbot.html)', 
            'SERVER_NAME' => 'localhost', 
            'SERVER_PORT' => '80', 
            'REMOTE_ADDR' => '::1', 
            'DOCUMENT_ROOT' => 'C:/www', 
            'REQUEST_SCHEME' => 'http', 
            'GATEWAY_INTERFACE' => 'CGI/1.1', 
            'SERVER_PROTOCOL' => 'HTTP/1.1', 
            'REQUEST_METHOD' => 'GET', 
            'QUERY_STRING' => '', 
            'PATH_INFO' => '/snapsearch/song.html.mp3?key=value', 
            'rack.url_scheme' => 'http', 
            'rack.input' => StringIO.new
        }
    end
    
    subject { described_class.new }
    
    describe '#detect' do
        
        describe 'When a request from a normal browser comes through' do
            
            let(:request) { Rack::Request.new(normal_browser) }
            
            it('should not be intercepted') { subject.detect(request: request).should == false }
            
        end
        
        describe 'When a request from a search engine robot comes through' do
            
            let(:request) { Rack::Request.new(search_engine) }
            
            it('should be intercepted') { subject.detect(request: request).should == true }
            
        end
        
        describe 'When a request from a SnapSearch robot comes through' do
            
            let(:request) { Rack::Request.new(snapsearch_robot) }
            
            it('should not be intercepted') { subject.detect(request: request).should == false }
            
        end
        
        describe 'When a non-GET request comes through' do
            
            let(:request) { Rack::Request.new(non_get_route) }
            
            it('should not be intercepted') { subject.detect(request: request).should == false }
            
        end
        
        describe 'When an ignored route request comes through' do
            
            let(:request) { Rack::Request.new(ignored_route) }
            
            it('should not be intercepted') { subject.detect(ignored_routes: [/^\/ignored/], request: request).should == false }
            
        end
        
        describe 'When a non-matched route request comes through' do
            
            let(:request) { Rack::Request.new(matched_route) }
            
            it('should not be intercepted') { subject.detect(matched_routes: [/^\/non_matched_route/], request: request).should == false }
            
        end
        
        describe 'When a matched route request comes through' do
            
            let(:request) { Rack::Request.new(matched_route) }
            
            it('should be intercepted') { subject.detect(matched_routes: [/^\/matched/], request: request).should == true }
            
        end
        
        describe 'When an escaped fragmented request comes through' do
            
            let(:request) { Rack::Request.new(basic_escaped_fragment_route) }
            
            it('should be intercepted') { subject.detect(request: request).should == true }
            
        end
        
        # TODO: Note that this is a false positive until the check_file_extensions option is implemented
        describe 'When other factors allow it and a valid file extension comes through' do
            
            let(:request) { Rack::Request.new(valid_file_extension_route) }
            
            it('should be intercepted') { subject.detect(request: request, check_file_extensions: true).should == true }
            
        end
        
        describe 'When an invalid file extension comes through' do
            
            let(:request) { Rack::Request.new(invalid_file_extension_route) }
            
            it('should not be intercepted') { subject.detect(request: request, check_file_extensions: true).should == false }
            
        end
        
        # TODO: Note that this is a false positive until the check_file_extensions option is implemented
        describe 'When other factors allow it and a nonexistent file extension comes through' do
            
            let(:request) { Rack::Request.new(nonexistent_file_extension_route) }
            
            it('should be intercepted') { subject.detect(request: request, check_file_extensions: true).should == true }
            
        end
        
        describe 'When custom extensions are set' do
            
            let(:request) { Rack::Request.new(mp3_file_extension_route) }
            
            it('should be intercepted correctly') do
                subject.detect(request: request, check_file_extensions: true).should == false
                
                subject.extensions['generic'] << 'mp3'
                
                subject.detect(request: request, check_file_extensions: true).should == true
                
                subject.extensions['generic'].delete('mp3')
                
                subject.detect(request: request, check_file_extensions: true).should == false
            end
            
        end
        
    end
    
    describe '#get_encoded_url' do
        
        let(:request) { Rack::Request.new(escaped_fragment_route) }
        let(:uri) { Addressable::URI.parse(request.url) }
        
        it 'should convert the escaped fragment route back to hash fragment' do
            subject.get_encoded_url(request.params, uri).should == 'http://localhost/snapsearch/path1?key1=value1#!/path2?key2=value2'
        end
        
    end
    
    describe '#get_decoded_path' do
        
        let(:uri) { Addressable::URI.parse('http://localhost:8080/some%20path/an%2Fother+path/path1.htm?key1=value%201%3F') }
        
        it 'should return the decoded path with the correct query and haash fragment' do
            subject.get_decoded_path( {}, uri ).should == '/some path/an/other+path/path1.htm?key1=value 1?'
        end
        
    end
    
end
