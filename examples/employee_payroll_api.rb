require 'rubygems'
require 'pp'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_KEYS = YAML.load_file(File.dirname(__FILE__) + '/xero_keys.yml')

gateway = XeroGateway::Gateway.new(XERO_KEYS["xero_consumer_key"], XERO_KEYS["xero_consumer_secret"])

# authorize in browser specific to payroll-API
%x(google-chrome #{gateway.request_token.authorize_url}"&scope=payroll.employees")

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp

gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

# Example of employee creation

# Employee initialization
employee = XeroGateway::Payroll::Employee.new(
  :gateway => gateway,
  :first_name => "EFirstName",
  :date_of_birth => "1980-01-01",
  :email => "myemployee@gmail.com",
  :gender => "M",
  :last_name => "ELastName",
  :middle_name => "EMiddle",
  :title => "Mr",
  :start_date => Date.today - 2.years,
  :occupation => "EOcc", 
  :mobile => "408-230-9732", 
  :phone => "0400-000-123"
)


# Add home_address
employee.home_address = XeroGateway::Payroll::HomeAddress.new(
  :address_line1 => "123 Main St", 
  :address_line2 => "124 Main St", 
  :address_line3 => "125 Main St", 
  :address_line4 => "126 Main St", 
  :city => "St. Kilda", 
  :country => "AUSTRALIA", 
  :postal_code => "3182", 
  :region  => "VIC"
)

#puts employee.to_xml

# Create employee to Xero
employee_creation_response = employee.create 

employee.employee_id = employee_creation_response.employee.employee_id


# Add bank_accounts
employee.bank_accounts = [
  XeroGateway::Payroll::BankAccount.new(
    :statement_text => "This is StatText", 
    :account_name => "XYZ Name", 
    :bsb => 987650, 
    :account_number => "987120000", 
    :remainder => true
  )
]

puts employee.update

# Add super_memberships
employee.super_memberships = [
  XeroGateway::Payroll::SuperMembership.new(
    :super_fund_id => "d972a5d1-e1ac-4e55-baf0-551dc16a7a4c", 
    :employee_number => "1234",     
    :super_membership_id => "4333d5cd-53a5-4c31-98e5-a8b4e5676b0b"
  )
]

puts employee.update

# Add pay_template
#employee.pay_template = XeroGateway::Payroll::PayTemplate.new(
#  :earnings_lines => [
#    XeroGateway::Payroll::EarningsLine.new(
#      :number_of_units_per_week => 38.0000, 
#      :annual_salary => 40000.0, 
#      :rate_per_unit => 40.0000, 
#      :normal_number_of_units => 37000.00, 
#      :earnings_rate_id => "a24dd671-afd3-49bf-a60e-88acd7faa9e4", 
#      :calculation_type => "ANNUALSALARY"
#    )
#  ]
#)

#puts employee.update

# Add tax_declaration
employee.tax_declaration = XeroGateway::Payroll::TaxDeclaration.new(
  :employment_basis => "FULLTIME", 
  :tfn_pending_or_exemption_held => false, 
  :tax_file_number => 123123129, 
  :australian_resident_for_tax_purposes => true, 
  :tax_free_threshold_claimed => true, 
  :tax_offset_estimated_amount => 10,
  :has_help_debt => true, 
  :has_sfss_debt => true, 
  :upward_variation_tax_withholding_amount => 50, 
  :eligible_to_receive_leave_loading => true,
  :approved_withholding_variation_percentage => 10
)

puts employee.update
puts employee.employee_id



