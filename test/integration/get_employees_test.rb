require File.dirname(__FILE__) + '/../test_helper'

class GetEmployeesTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Employees$/ }.returns(get_file_as_string("employees.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("employees.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("employees.xml"))
    end
  end

  def test_get_employees
    # Make sure there is an employee in Xero to retrieve
    employee = @gateway.create_employee(dummy_employee).employee
    flunk "get_employees could not be tested because create_employee failed" if employee.nil?

    result = @gateway.get_employees
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.employees.collect {|e| e.employee_id}.include?(employee.employee_id)
  end

  # Make sure that a reference to gateway is passed when the get_employees response is parsed.
  def test_get_employees_gateway_reference
    result = @gateway.get_employees
    assert(result.success?)
    assert_not_equal(0, result.employees.size)

    result.employees.each do | employee |
      assert(employee.gateway === @gateway)
    end
  end

end