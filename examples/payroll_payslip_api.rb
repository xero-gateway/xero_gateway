require 'rubygems'
require 'pp'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_KEYS = YAML.load_file(File.dirname(__FILE__) + '/xero_keys.yml')

gateway = XeroGateway::Gateway.new(XERO_KEYS["xero_consumer_key"], XERO_KEYS["xero_consumer_secret"])

# authorize in browser specific to payroll-API
%x(open #{gateway.request_token.authorize_url}"&scope=payroll.payslip, payroll.payrollcalendars, payroll.payruns")

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp

gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

pp "**** Get Payroll PaySlip By ID '42270f29-378e-43ce-bd48-2f7a2547038d'"
# Example payslip-API calls
payslip = gateway.get_payroll_payslip_by_id("42270f29-378e-43ce-bd48-2f7a2547038d").response_item
pp payslip

pp "**** Get Payroll Calendars"
payroll_calendars = gateway.get_payroll_calendars.response_item
pp payroll_calendars

pp "**** Get Payroll Calendar By ID"
payroll_calendars = gateway.get_payroll_calendar_by_id(payroll_calendars.first.payroll_calendar_id).response_item
pp payroll_calendars

pp "**** Get Payroll PaySlip's Earning Lines"
pp payslip.earnings_lines
