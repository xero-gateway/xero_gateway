require 'rubygems'
require 'pp'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_CONSUMER_KEY    = "M2YYZMRJNJHMZDE3NDZKODHJMDAWNZ"
XERO_CONSUMER_SECRET = "MGY4MMY2MGNIMWY0NGVINMJJMZLLND"

gateway = XeroGateway::Gateway.new(XERO_CONSUMER_KEY, XERO_CONSUMER_SECRET)

# authorize in browser
#{}%x(open #{gateway.request_token.authorize_url})

#puts "Enter the verification code from Xero?"
#oauth_verifier = gets.chomp  

#gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

gateway.authorize_from_access("ZMU0MMU4ZWM3MTAWNGM2NJHIZJQZNT", "LFP0MMFAQ0CQSVT4O5CXZI3ALEKHHN")

puts "Your access token: #{gateway.access_token.token} / #{gateway.access_token.secret}"
puts "(Good for 30 minutes)"

# Example API Call
#pp gateway.get_contacts.contacts

gateway.get_invoice_by_id("bogusid")
