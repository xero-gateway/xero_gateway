module XeroGateway
  module Http
    OPEN_TIMEOUT = 10 unless defined? OPEN_TIMEOUT
    READ_TIMEOUT = 60 unless defined? READ_TIMEOUT
    ROOT_CA_FILE = File.join(File.dirname(__FILE__), 'ca-certificates.crt') unless defined? ROOT_CA_FILE
    
    def http_get(url, extra_params = {})
      http_request(:get, url, nil, extra_params)
    end

    def http_post(url, body, extra_params = {})
      http_request(:post, url, body, extra_params)
    end

    def http_put(url, body, extra_params = {})
      http_request(:put, url, body, extra_params)
    end
    
    private
    
      def http_request(method, url, body, extra_params = {})
        headers = {} 

        if method != :get
         headers['Content-Type'] ||= "application/x-www-form-urlencoded"
        end

        params = {:apiKey => @api_key, :xeroKey => @customer_key}
        params = params.merge(extra_params).map {|key,value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"}.join("&")

        uri   = URI.parse(url + "?" + params)

        # Only setup @cached_http once on first use as loading the CA file is quite expensive computationally.
        unless @cached_http && @cached_http.address == uri.host && @cached_http.port == uri.port
          @cached_http = Net::HTTP.new(uri.host, uri.port) 
          @cached_http.open_timeout = OPEN_TIMEOUT
          @cached_http.read_timeout = READ_TIMEOUT
          @cached_http.use_ssl      = true

          # Need to validate server's certificate against root certificate authority to prevent man-in-the-middle attacks.
          @cached_http.ca_file        = ROOT_CA_FILE
          # http.verify_mode    = OpenSSL::SSL::VERIFY_NONE
          @cached_http.verify_mode    = OpenSSL::SSL::VERIFY_PEER
          @cached_http.verify_depth   = 5
        end

        case method
          when :get   then    @cached_http.get(uri.request_uri, headers).body
          when :post  then    @cached_http.post(uri.request_uri, body, headers).body
          when :put   then    @cached_http.put(uri.request_uri, body, headers).body
        end
      end
       
  end
end