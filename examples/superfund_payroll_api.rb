require 'rubygems'
require 'pp'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_KEYS = YAML.load_file(File.dirname(__FILE__) + '/xero_keys.yml')

gateway = XeroGateway::Gateway.new(XERO_KEYS["xero_consumer_key"], XERO_KEYS["xero_consumer_secret"])

# authorize in browser specific to payroll-API
%x(open #{gateway.request_token.authorize_url}"&scope=payroll.employees,payroll.superfunds")

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp

gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

responses = gateway.get_payroll_super_funds
puts responses.response_xml
super_funds = responses.response_item
pp super_funds.inspect

super_fund = gateway.get_payroll_super_fund_by_id(super_funds.super_fund_id)
pp super_fund.response_xml
pp super_fund.response_item.inspect
