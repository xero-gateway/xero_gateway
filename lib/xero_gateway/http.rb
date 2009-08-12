module XeroGateway
  module Http
    OPEN_TIMEOUT = 10 unless defined? OPEN_TIMEOUT
    READ_TIMEOUT = 60 unless defined? READ_TIMEOUT

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

        http = Net::HTTP.new(uri.host, uri.port) 
        http.open_timeout = OPEN_TIMEOUT
        http.read_timeout = READ_TIMEOUT
        http.use_ssl      = true

        http.verify_mode    = OpenSSL::SSL::VERIFY_NONE

        case method
          when :get   then    http.get(uri.request_uri, headers).body
          when :post  then    http.post(uri.request_uri, body, headers).body
          when :put   then    http.put(uri.request_uri, body, headers).body
        end
      end
       
  end
end