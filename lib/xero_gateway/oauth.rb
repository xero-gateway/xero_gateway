module XeroGateway
  
  # Shamelessly based on the Twitter Gem's OAuth implementation by John Nunemaker
  # Thanks!
  # 
  # http://twitter.rubyforge.org/
  # http://github.com/jnunemaker/twitter/
  
  class OAuth
    
    class TokenExpired < StandardError; end
    class TokenInvalid < StandardError; end
        
    unless defined? XERO_CONSUMER_OPTIONS
      XERO_CONSUMER_OPTIONS = {
        :site               => "https://api.xero.com",
        :request_token_path => "/oauth/RequestToken",
        :access_token_path  => "/oauth/AccessToken",
        :authorize_path     => "/oauth/Authorize"
      }.freeze
    end
    
    extend Forwardable
    def_delegators :access_token, :get, :post, :put
    
    attr_reader :ctoken, :csecret, :consumer_options
    
    def initialize(ctoken, csecret, options = {})
      @ctoken, @csecret = ctoken, csecret
      @consumer_options = XERO_CONSUMER_OPTIONS.merge(options)
    end
    
    def consumer
      @consumer ||= ::OAuth::Consumer.new(@ctoken, @csecret, consumer_options)
    end
    
    def request_token(params = {})
      @request_token ||= consumer.get_request_token(params)
    end
    
    def authorize_from_request(rtoken, rsecret, params = {})
      request_token     = ::OAuth::RequestToken.new(consumer, rtoken, rsecret)
      access_token      = request_token.get_access_token(params)
      @atoken, @asecret = access_token.token, access_token.secret
    end
    
    def access_token
      @access_token ||= ::OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end
    
    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end
    
  end
end