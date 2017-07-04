require 'rubygems'
require 'pp'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_CONSUMER_KEY    = "YOUR CONSUMER KEY"
XERO_CONSUMER_SECRET = "YOUR CONSUMER SERET"

PRIVATE_KEY          = "YOUR_PRIVATE_KEY.pem"

gateway = XeroGateway::PartnerApp.new(XERO_CONSUMER_KEY, XERO_CONSUMER_SECRET, 
                                      :private_key_file => File.join(File.dirname(__FILE__), PRIVATE_KEY))

# authorize in browser
%x(open #{gateway.request_token.authorize_url})

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp  

gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

puts "Your access token/secret: #{gateway.access_token.token}, #{gateway.access_token.secret}. Expires: #{gateway.expires_at}"
puts "(Good for 30 Minutes - but we can renew it!)"

puts "Session Handle: #{gateway.session_handle}"

# Example API Call
pp gateway.get_contacts.contacts.map(&:name)

# Renew!
gateway.renew_access_token(gateway.access_token.token, gateway.access_token.secret, gateway.session_handle)
puts "Your renewed access token/secret is:  #{gateway.access_token.token}, #{gateway.access_token.secret}. Expires: #{gateway.expires_at}"
