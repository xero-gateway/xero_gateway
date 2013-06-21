require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollEmployeesTest < Test::Unit::TestCase
  include TestHelper

  INVALID_PAYROLL_EMPLOYEE_ID = "9157d509-4d61-46f1-bb6c-zzzzxxxx1234" unless defined?(INVALID_PAYROLL_EMPLOYEE_ID)

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Employees$/ }.returns(get_file_as_string("payroll_employees.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("payroll_employee.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("payroll_employee.xml"))

      # Get a bank transaction with an invalid ID. 
      @gateway.stubs(:http_get).with {|client, url, params| url =~ Regexp.new("BankTransactions/#{INVALID_PAYROLL_EMPLOYEE_ID}") }.returns(get_file_as_string("payroll_employee_not_found_error.xml"))
    end
  end

  def test_get_payroll_employees
    # Make sure there is an employee in Xero to retrieve
    employee = @gateway.create_payroll_employee(dummy_payroll_employee).employee
    flunk "get_payroll_employees could not be tested because create_payroll_employee failed" if employee.nil?

    result = @gateway.get_payroll_employees
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.employees.collect {|e| e.employee_id}.include?(employee.employee_id)
  end

  # Make sure that a reference to gateway is passed when the get_payroll_employees response is parsed.
  def test_get_payroll_employees_gateway_reference
    result = @gateway.get_payroll_employees
    assert(result.success?)
    assert_not_equal(0, result.employees.size)

    result.employees.each do | employee |
      assert_not_equal employee.first_name, nil
      assert_not_equal employee.last_name, nil
    end
  end

end