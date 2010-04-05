module XeroGateway
  class PrivateApp < Gateway
    #
    # The consumer key and secret here correspond to those provided
    # to you by Xero inside the API Previewer. 
    def initialize(consumer_key, consumer_secret, path_to_private_key, options = {})
      options.merge!(
        :signature_method => 'RSA-SHA1',
        :private_key_file => path_to_private_key
      )
      
      @xero_url = options[:xero_url] || "https://api.xero.com/api.xro/2.0"
      @client   = OAuth.new(consumer_key, consumer_secret, options)
      @client.authorize_from_access(consumer_key, consumer_secret)
    end
  end
end
