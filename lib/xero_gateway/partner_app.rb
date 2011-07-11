module XeroGateway
  class PartnerApp < Gateway
    
    class CertificateRequired < StandardError; end
    
    NO_SSL_CLIENT_CERT_MESSAGE   = "You need to provide a client ssl certificate and key pair (these are the ones you got from Entrust and should not be password protected) as :ssl_client_cert and :ssl_client_key (should be .crt or .pem files)"
    NO_PRIVATE_KEY_ERROR_MESSAGE = "You need to provide your private key (corresponds to the public key you uploaded at api.xero.com) as :private_key_file (should be .crt or .pem files)"
    
    def_delegators :client, :session_handle, :renew_access_token, :authorization_expires_at
     
    def initialize(consumer_key, consumer_secret, options = {})
      
      raise CertificateRequired.new(NO_SSL_CLIENT_CERT_MESSAGE)   unless options[:ssl_client_cert]
      raise CertificateRequired.new(NO_SSL_CLIENT_CERT_MESSAGE)   unless options[:ssl_client_key]
      raise CertificateRequired.new(NO_PRIVATE_KEY_ERROR_MESSAGE) unless options[:private_key_file]
      
      options.merge!(
        :site             => "https://api-partner.network.xero.com",
        :authorize_url    => 'https://api.xero.com/oauth/Authorize', 
        :signature_method => 'RSA-SHA1',
        :ssl_client_cert  => OpenSSL::X509::Certificate.new(File.read(options[:ssl_client_cert])),
        :ssl_client_key   => OpenSSL::PKey::RSA.new(File.read(options[:ssl_client_key])),
        :private_key_file => options[:private_key_file]
      )
      
      @xero_url = options[:xero_url] || "https://api-partner.xero.com/api.xro/2.0"  
      @client   = OAuth.new(consumer_key, consumer_secret, options)
    end

    def set_session_handle(handle)
      client.session_handle = handle
    end
    
  end
end
