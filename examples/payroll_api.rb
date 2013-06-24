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

# Example payroll-API calls
payroll_employees = gateway.get_payroll_employees.employees.map(&:employee_id)

pp "**** get_payroll_employees"
pp payroll_employees

# Retrieves Employee details and includes HomeAddress
pp "**** get_payroll_employee_by_id"
payroll_employee = gateway.get_payroll_employee_by_id(payroll_employees.first)
pp "**** response_item"
pp payroll_employee.response_item
pp "**** home_address"
pp payroll_employee.response_item.home_address.address_line1

# Retrieves Employee Super details
pp "**** get_payroll_super_fund_by_id"
pp payroll_employee.response_item.super_memberships

#check if the employee have "super_memberships" or not
if payroll_employee.response_item.super_memberships.blank?
	payroll_employee = gateway.get_payroll_employee_by_id(payroll_employees[1])
end

pp gateway.get_payroll_super_fund_by_id(payroll_employee.response_item.super_memberships.first.super_fund_id)

# Retrieves all Super Funds
pp "**** get_payroll_super_funds"
pp gateway.get_payroll_super_funds

# Push employee details via Payroll API
pp "**** pushing payroll employees"
employee = gateway.build_payroll_employee({first_name: "Dominic", last_name: "Wroblewski", gender: "M", title: "Mr", mobile: "07872388552"})
pp "**** employee"
pp employee
pp "**** saving employee"
gateway.create_payroll_employee(employee)

# Update employee's home address via Payroll API
pp "**** Update payroll employee with bank account"
employee.home_address = XeroGateway::Payroll::HomeAddress.new(
    :address_line1 => "Address line 1 St",
    :address_line2 => "Apt Address Line 2",
    :address_line3 => "This is Address line 3",
    :city => "My city",
    :postal_code => "2060",
    :region => "NSW",
    :country => "Australia"
  )
gateway.update_payroll_employee(employee)
pp "**** employee with bank account"
pp employee

# Update employee's bank account via Payroll API
pp "**** Update payroll employee with bank account"
employee.bank_accounts = [
  XeroGateway::Payroll::BankAccount.new(
    :statement_text => "This is StatText",
    :account_name => "XYZ Name",
    :bsb => 987650,
    :account_number => "987120000",
    :remainder => true
  )
]
gateway.update_payroll_employee(employee)
pp "**** employee with bank account"
pp employee


# Update employee's super memberships via Payroll API
pp "**** Update payroll employee with super memberships"
employee.super_memberships = [
  XeroGateway::Payroll::SuperMembership.new(
    :super_fund_id => "#{payroll_employee.response_item.super_memberships.first.super_fund_id}",
    :employee_number => "1234",
    :super_membership_id => "#{payroll_employee.response_item.super_memberships.first.super_membership_id}"
  )
]
gateway.update_payroll_employee(employee)
pp "**** employee with super memberships"
pp employee

# # Update employee's pay template via Payroll API
# pp "**** Update payroll employee with pay template"
# employee.pay_template = XeroGateway::Payroll::PayTemplate.new(
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
# )
# pp "**** update employee with pay template"
# gateway.update_payroll_employee(employee)
# pp "**** employee with pay template"
# pp employee

# Update employee's tax declaration via Payroll API
pp "**** Update payroll employee with tax declaration"
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
gateway.update_payroll_employee(employee)
pp "**** employee with tax declaration"
pp employee

# Try and get invalid payroll employee by ID
pp "**** get_payroll_employee_by_id with invalid ID"
begin
  response = gateway.get_payroll_employee_by_id("123123123123123")
rescue XeroGateway::EmployeeNotFoundError => e
  pp "**** exception response"
  pp e
end

# Update an existing Employee based on EmployeeID
pp "**** update_payroll_employee"
timestamp = Time.now.to_s.split
middle_name = "#{timestamp[0]} #{timestamp[1]}"
employee = gateway.build_payroll_employee({employee_id: payroll_employees.first, middle_name: middle_name})
pp "Updated middle_name: " + middle_name
gateway.update_payroll_employee(employee)
