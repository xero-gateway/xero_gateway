module XeroGateway

  # Shamelessly based on the Twitter Gem's OAuth implementation by John Nunemaker
  # Thanks!
  #
  # http://twitter.rubyforge.org/
  # http://github.com/jnunemaker/twitter/

  class OAuth

    class TokenExpired < StandardError; end
    class TokenInvalid < StandardError; end
    class RateLimitExceeded < StandardError; end
    class ConsumerConfigError < StandardError; end
    class UnknownError < StandardError; end

    unless defined? XERO_CONSUMER_OPTIONS
      XERO_CONSUMER_OPTIONS = {
        :site               => "https://api.xero.com",
        :request_token_path => "/oauth/RequestToken",
        :access_token_path  => "/oauth/AccessToken",
        :authorize_path     => "/oauth/Authorize"
      }.freeze
    end

    attr_reader   :ctoken, :csecret, :consumer_options, :authorization_expires_at, :expires_at
    attr_accessor :session_handle

    def initialize(ctoken, csecret, options = {})
      @ctoken, @csecret = ctoken, csecret
      
      # Allow user-agent base val for certification procedure (enforce for PartnerApp)
      @base_headers = {}
      @base_headers["User-Agent"] = options.delete(:user_agent) if options.has_key?(:user_agent)

      @consumer_options = XERO_CONSUMER_OPTIONS.merge(options)
    end

    def consumer
      @consumer ||= ::OAuth::Consumer.new(@ctoken, @csecret, consumer_options)
    end

    def request_token(params = {})
      # Underlying oauth consumer accepts body params and headers for request via positional params - explicit nilling of 
      #  body parameters allows for correct position for headers
      @request_token ||= consumer.get_request_token(params, nil, @base_headers)
    end

    def authorize_from_request(rtoken, rsecret, params = {})
      request_token     = ::OAuth::RequestToken.new(consumer, rtoken, rsecret)
      # Underlying oauth consumer accepts body params and headers for request via positional params - explicit nilling of 
      #  body parameters allows for correct position for headers
      access_token      = request_token.get_access_token(params, nil, @base_headers)
      @atoken, @asecret = access_token.token, access_token.secret

      update_attributes_from_token(access_token)
    end

    def access_token
      @access_token ||= ::OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end

    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end

    # Renewing access tokens only works for Partner applications
    def renew_access_token(access_token = nil, access_secret = nil, session_handle = nil)
      access_token   ||= @atoken
      access_secret  ||= @asecret
      session_handle ||= @session_handle

      old_token = ::OAuth::RequestToken.new(consumer, access_token, access_secret)

      # Underlying oauth consumer accepts body params and headers for request via positional params - explicit nilling of 
      #  body parameters allows for correct position for headers
      access_token = old_token.get_access_token({
        :oauth_session_handle => session_handle,
        :token                => old_token
      }, nil, @base_headers)

      update_attributes_from_token(access_token)
    rescue ::OAuth::Unauthorized => e
      #note that e.request is a Net::HTTP _response_
      error_details = CGI.parse(e.request.body.strip)

      #Xero will respond with 401 in a variety of circumstances, which will surface as OAuth::Unauthorized errors,
      # but may have different remedies (user needs to re-authorize, developer must fix configuration for client, etc.).
      #Cases are distinguishable by `oauth_problem` response body parameter - message is oauth_problem_advice to be 
      #   consistent with XeroGateway::Http#handle_oauth_error!
      #https://developer.xero.com/documentation/auth-and-limits/oauth-issues
      problem = error_details['oauth_problem'].first
      description = error_details["oauth_problem_advice"].first 
      description = "No description found: #{e.request.plain_body}" if description.blank?
      
      if problem == 'consumer_key_unknown'
        raise XeroGateway::OAuth::ConsumerConfigError.new(description)
      else
        # If the original access token is for some reason invalid an OAuth::Unauthorized could be raised.
        # In this case raise a XeroGateway::OAuth::TokenInvalid which can be captured by the caller.  In this
        # situation the end user will need to re-authorize the application via the request token authorization URL
        raise XeroGateway::OAuth::TokenInvalid.new(description)
      end
    end

    def get(path, headers = {})
      access_token.get(path, headers.merge(@base_headers))
    end
      
    def post(path, body = '', headers = {})
      access_token.post(path, body, headers.merge(@base_headers))
    end
      
    def put(path, body = '', headers = {})
      access_token.put(path, body, headers.merge(@base_headers))
    end
    
    def delete(path, headers = {})
      access_token.delete(path, headers.merge(@base_headers))
    end

    private

      # Update instance variables with those from the AccessToken.
      def update_attributes_from_token(access_token)
        @expires_at               = Time.now + access_token.params[:oauth_expires_in].to_i
        @authorization_expires_at = Time.now + access_token.params[:oauth_authorization_expires_in].to_i
        @session_handle           = access_token.params[:oauth_session_handle]
        @atoken, @asecret         = access_token.token, access_token.secret
        @access_token             = nil
      end

  end
end
