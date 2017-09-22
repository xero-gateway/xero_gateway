module XeroGateway
  class PartnerApp < Gateway

    class CertificateRequired < StandardError; end

    NO_PRIVATE_KEY_ERROR_MESSAGE = "You need to provide your private key (corresponds to the public key you uploaded at api.xero.com) as :private_key_file (should be .crt or .pem files)"
    
    def_delegators :client, :session_handle, :renew_access_token, :authorization_expires_at

    def initialize(consumer_key, consumer_secret, options = {})
      raise CertificateRequired.new(NO_PRIVATE_KEY_ERROR_MESSAGE) unless options[:private_key_file]
      
      #required by Xero for new partner apps, but only issuing warning to keep backward compat for any grandfathered apps
      puts "WARNING: a unique User-Agent header is required for Xero partner apps, and is missing - this should be supplied as :user_agent" unless options[:user_agent]

      defaults = {
        :site             => "https://api.xero.com",
        :authorize_url    => 'https://api.xero.com/oauth/Authorize',
        :signature_method => 'RSA-SHA1',
      }

      options = defaults.merge(options)

      super(consumer_key, consumer_secret, defaults.merge(options))
    end

    def set_session_handle(handle)
      client.session_handle = handle
    end

  end
end
