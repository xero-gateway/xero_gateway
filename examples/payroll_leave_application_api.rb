require 'rubygems'
require 'pp'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

XERO_KEYS = YAML.load_file(File.dirname(__FILE__) + '/xero_keys.yml')

gateway = XeroGateway::Gateway.new(XERO_KEYS["xero_consumer_key"], XERO_KEYS["xero_consumer_secret"])

# authorize in browser specific to payroll-API
%x(open #{gateway.request_token.authorize_url}"&scope=payroll.employees,payroll.payitems, payroll.leaveapplications")

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp

gateway.authorize_from_request(gateway.request_token.token, gateway.request_token.secret, :oauth_verifier => oauth_verifier)

# Example payitems-API calls
payroll_pay_items = gateway.get_payroll_pay_items.response_item
gateway.get_payroll_employees.employees.map(&:employee_id)

pp "**** Get Payroll Pay Items"
pp payroll_pay_items


pp "**** Leave Types"
#Leave Types
leave_types = payroll_pay_items.leave_types
pp leave_types

# Leave Applications
pp "**** Leave Applications"
payroll_leave_applications = gateway.get_payroll_leave_applications.response_item
pp payroll_leave_applications

# Get employees
payroll_employee_ids = gateway.get_payroll_employees.employees.map(&:employee_id)

pp "**** get_payroll_employees"
pp payroll_employee_ids


#Create New LeaveApplication
new_payroll_leave_application = gateway.build_payroll_leave_application({:leave_type_id => leave_types.first.leave_type_id,
																															 :employee_id => payroll_employee_ids.first,
																															 :title => "My leave_application",
																															 :start_date => Date.today,
																															 :end_date => Date.today + 1.week,
																															 :description => "My Description",
																															 :leave_periods => [XeroGateway::Payroll::LeavePeriod.new(
																																									    :number_of_units => 3,
																																									    :pay_period_end_date => Date.today + 1.month,
																																									    :pay_period_start_date => Date.today,
																																									    :leave_period_status => "SCHEDULED"
																																									  )
																																									]
																															})

pp "**** Saving Leave Application"
gateway.create_payroll_leave_application(new_payroll_leave_application)
pp "**** New Leave Application"
pp new_payroll_leave_application

# Get Leave Application by ID
pp "**** Get Leave Application By ID"
payroll_leave_application = gateway.get_payroll_leave_application_by_id(new_payroll_leave_application.leave_application_id).response_item
pp payroll_leave_application

# Update A Leave Application
pp "**** Update A Leave Application"
pp "**** Old Leave Application Description: #{payroll_leave_applications.first.description}"
leave_application = gateway.build_payroll_leave_application({employee_id: payroll_leave_applications.first.employee_id,
																														 start_date: payroll_leave_applications.first.start_date.to_datetime,
																														 end_date: payroll_leave_applications.first.start_date.to_datetime + 1.week,
																														 leave_application_id: payroll_leave_applications.first.leave_application_id,
																														 description: "New Leave Application Description"})
pp leave_application.to_xml
gateway.update_payroll_leave_application(leave_application)
updated_payroll_leave_application = gateway.get_payroll_leave_application_by_id(payroll_leave_applications.first.leave_application_id)
pp "Updated Leave Application Description: " + updated_payroll_leave_application.response_item.description
