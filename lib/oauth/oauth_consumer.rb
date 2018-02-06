module OAuth
  class Consumer
    def http_with_ssl_client_certificates(*args)
      @http ||= http_without_ssl_client_certificates(*args).tap do |http|
        http.cert = options[:ssl_client_cert]
        http.key  = options[:ssl_client_key]
      end
    end

    alias_method :ssl_client_certificates, :http
    alias_method :http, :ssl_client_certificates
  end
end
