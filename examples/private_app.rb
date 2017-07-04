require 'rubygems'
require 'pp'

require_relative '../lib/xero_gateway.rb'

XERO_CONSUMER_KEY    = "YOUR CONSUMER KEY"
XERO_CONSUMER_SECRET = "YOUR CONSUMER SECRET"
PATH_TO_PRIVATE_KEY  = "/path/to/privatekey.pem"

gateway = XeroGateway::PrivateApp.new(
  XERO_CONSUMER_KEY,
  XERO_CONSUMER_SECRET,
  PATH_TO_PRIVATE_KEY)

# Example API Call
pp gateway.get_contacts.contacts


