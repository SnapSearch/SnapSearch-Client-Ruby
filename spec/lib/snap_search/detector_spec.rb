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
      'PATH_INFO' => '/snapsearch?&_escaped_fragment_',
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
      'PATH_INFO' => '/snapsearch/path1?key1=value1&_escaped_fragment_=%2Fpath2%3Fkey2=value2',
      'rack.url_scheme' => 'http', 
      'rack.input' => StringIO.new
    }
  end
  
  describe 'When a request from a normal browser comes through' do
    
    let(:request) { Rack::Request.new(normal_browser) }
    
    subject { described_class.new(request: request) }
    
    it('should not be intercepted') { subject.detect.should == false }
    
  end
  
  describe 'When a request from a search engine robot comes through' do
    
    let(:request) { Rack::Request.new(search_engine) }
    
    subject { described_class.new(request: request) }
    
    it('should be intercepted') { subject.detect.should == true }
    
  end
  
  describe 'When a request from a SnapSearch robot comes through' do
    
    let(:request) { Rack::Request.new(snapsearch_robot) }
    
    subject { described_class.new(request: request) }
    
    it('should not be intercepted') { subject.detect.should == false }
    
  end
  
  describe 'When a non-GET request comes through' do
    
    let(:request) { Rack::Request.new(non_get_route) }
    
    subject { described_class.new(request: request) }
    
    it('should not be intercepted') { subject.detect.should == false }
    
  end
  
  describe 'When an ignored route request comes through' do
    
    let(:request) { Rack::Request.new(ignored_route) }
    
    subject { described_class.new(ignored_routes: [/^\/ignored/], request: request) }
    
    it('should not be intercepted') { subject.detect.should == false }
    
  end
  
  describe 'When a non-matched route request comes through' do
    
    let(:request) { Rack::Request.new(matched_route) }
    
    subject { described_class.new(matched_routes: [/^\/non_matched_route/], request: request) }
    
    it('should not be intercepted') { subject.detect.should == false }
    
  end
  
  describe 'When a matched route request comes through' do
    
    let(:request) { Rack::Request.new(matched_route) }
    
    subject { described_class.new(matched_routes: [/^\/matched/], request: request) }
    
    it('should be intercepted') { subject.detect.should == true }
    
  end
  
  describe 'When an escaped fragmented request comes through' do
    
    let(:request) { Rack::Request.new(basic_escaped_fragment_route) }
    
    subject { described_class.new(request: request) }
    
    it('should be intercepted') { subject.detect.should == true }
    
  end
  
  describe '#get_encoded_url' do
    
    let(:request) { Rack::Request.new(escaped_fragment_route) }
    
    subject { described_class.new(request: request) }
    
    it 'should convert the escaped fragment route back to hash fragment' do
      subject.get_encoded_url.should == 'http://localhost/snapsearch/path1?key1=value1#!/path2?key2=value2'
    end
    
  end
  
end
