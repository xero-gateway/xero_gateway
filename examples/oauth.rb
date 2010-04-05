require 'rubygems'
require 'pp'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_CONSUMER_KEY    = "YOUR-OAUTH-CONSUMER-KEY"
XERO_CONSUMER_SECRET = "YOUR-OAUTH-CONSUMER-SECRET"

gateway = XeroGateway::Gateway.new(XERO_CONSUMER_KEY, XERO_CONSUMER_SECRET)

# authorize in browser
%x(open #{gateway.request_token.authorize_url})

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp  

gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

puts "Your access token: #{gateway.access_token}"
puts "(Good for 30 minutes)"

# Example API Call
pp gateway.get_contacts.contacts


