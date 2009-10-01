# Shamelessly based on the xero Gem's OAuth implementation by John Nunemaker
# Thanks!
# 
# http://xero.rubyforge.org/
# http://github.com/jnunemaker/xero/

require File.join(File.dirname(__FILE__), '../test_helper.rb')

class OAuthTest < Test::Unit::TestCase
  should "initialize with consumer token and secret" do
    xero = XeroGateway::OAuth.new('token', 'secret')
    
    assert_equal 'token',  xero.ctoken
    assert_equal 'secret', xero.csecret
  end
  
  should "set autorization path to '/oauth/authorize' by default" do
    xero = XeroGateway::OAuth.new('token', 'secret')
    assert_equal '/oauth/Authorize', xero.consumer.options[:authorize_path] 
  end
  
  should "have a consumer" do
    consumer = mock('oauth consumer')
    OAuth::Consumer.expects(:new).with('token', 'secret', XeroGateway::OAuth::XERO_CONSUMER_OPTIONS).returns(consumer)
    
    xero = XeroGateway::OAuth.new('token', 'secret')
    
    assert_equal consumer, xero.consumer
  end
  
  should "have a request token from the consumer" do
    consumer = mock('oauth consumer')
    request_token = mock('request token')
    consumer.expects(:get_request_token).returns(request_token)
    OAuth::Consumer.expects(:new).with('token', 'secret', XeroGateway::OAuth::XERO_CONSUMER_OPTIONS).returns(consumer)
    xero = XeroGateway::OAuth.new('token', 'secret')
    
    assert_equal request_token, xero.request_token
  end
  
  should "be able to create access token from request token and secret" do
    xero = XeroGateway::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret')
    xero.stubs(:consumer).returns(consumer)
    
    access_token = mock('access token', :token => 'atoken', :secret => 'asecret')
    request_token = mock('request token')
    request_token.expects(:get_access_token).returns(access_token)
    OAuth::RequestToken.expects(:new).with(consumer, 'rtoken', 'rsecret').returns(request_token)
    
    xero.authorize_from_request('rtoken', 'rsecret')
    assert xero.access_token.is_a? OAuth::AccessToken
    assert_equal "atoken",  xero.access_token.token
    assert_equal "asecret", xero.access_token.secret
  end
  
  should "be able to create access token from access token and secret" do
    xero = XeroGateway::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret')
    xero.stubs(:consumer).returns(consumer)
    
    xero.authorize_from_access('atoken', 'asecret')
    assert xero.access_token.is_a? OAuth::AccessToken
    assert_equal "atoken",  xero.access_token.token
    assert_equal "asecret", xero.access_token.secret
  end

  # Xero doesn't support OAuth Callbacks, not that this calls to Xero anyway :)
  # See: http://blog.xero.com/developer/api-overview/ 
  #
  # should "be able to create request token with callback url" do
  #   xero = XeroGateway::OAuth.new('token', 'secret')
  #   consumer = OAuth::Consumer.new('token', 'secret')
  #   xero.stubs(:consumer).returns(consumer)
  # 
  #   request_token = mock('request token')
  #   consumer.expects(:get_request_token).with(:oauth_callback => "http://callback.com").returns(request_token)
  # 
  #   xero.request_token(:oauth_callback => "http://callback.com")
  # end
  
  should "be able to create access token with oauth verifier" do
    xero = XeroGateway::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret')
    xero.stubs(:consumer).returns(consumer)
    
    access_token = mock('access token', :token => 'atoken', :secret => 'asecret')
    request_token = mock('request token')
    request_token.expects(:get_access_token).with(:oauth_verifier => "verifier").returns(access_token)
    OAuth::RequestToken.expects(:new).with(consumer, 'rtoken', 'rsecret').returns(request_token)
    
    xero.authorize_from_request('rtoken', 'rsecret', :oauth_verifier => "verifier")
  end
  
  should "delegate get to access token" do
    access_token = mock('access token')
    xero = XeroGateway::OAuth.new('token', 'secret')
    xero.stubs(:access_token).returns(access_token)
    access_token.expects(:get).returns(nil)
    xero.get('/foo')
  end
  
  should "delegate post to access token" do
    access_token = mock('access token')
    xero = XeroGateway::OAuth.new('token', 'secret')
    xero.stubs(:access_token).returns(access_token)
    access_token.expects(:post).returns(nil)
    xero.post('/foo')
  end
end