module XeroGateway
  # @see OAuth2 Support in Readme.md
  # Wraps an OAuth2::AccessToken object to behave like XeroGateway 
  # expects a legacy OAuth client object to behave for executing
  # requests.
  class Oauth2ClientAdapter
    attr_accessor :access_token, :tenant_id

    def initialize(access_token, tenant_id)
      @access_token = access_token
      @tenant_id = tenant_id
    end

    def get(uri, headers)
      wrap_request(:get, uri, { headers: headers_with_tenant(headers) })
    end

    def post(uri, params, headers)
      wrap_request(:post, uri, { body: params, headers: headers_with_tenant(headers) })
    end

    def put(uri, params, headers)
      wrap_request(:put, uri, { body: params, headers: headers_with_tenant(headers) })
    end

    protected

    def wrap_request(method, uri, opts)
      ResponseAdapter.new(@access_token.request(method, uri, opts))
    end

    def headers_with_tenant(headers)
      { 'xero-tenant-id' => tenant_id }.merge(headers)
    end

    # Wraps an OAuth2::Response object to behave like XeroGateway 
    # expects legacy, monkey-patched responses.
    class ResponseAdapter
      def initialize(response)
        @response = response
      end

      def code
        @response.status
      end

      def plain_body
        @response.body
      end
    end
  end
end
