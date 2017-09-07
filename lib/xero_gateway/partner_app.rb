module XeroGateway
  class PartnerApp < Gateway

    class CertificateRequired < StandardError; end
    class UserAgentRequired < StandardError; end

    NO_PRIVATE_KEY_ERROR_MESSAGE = "You need to provide your private key (corresponds to the public key you uploaded at api.xero.com) as :private_key_file (should be .crt or .pem files)"
    NO_USER_AGENT_ERROR_MESSAGE = "a unique User-Agent header is required for partner apps and should be supplied as :user_agent"

    def_delegators :client, :session_handle, :renew_access_token, :authorization_expires_at

    def initialize(consumer_key, consumer_secret, options = {})
      raise CertificateRequired.new(NO_PRIVATE_KEY_ERROR_MESSAGE) unless options[:private_key_file]
      raise UserAgentRequired.new(NO_USER_AGENT_ERROR_MESSAGE) unless options[:user_agent]

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
