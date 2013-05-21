require File.dirname(__FILE__) + '/../test_helper'

class GetEmployeeTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Employees\/[^\/]+$/ }.returns(get_file_as_string("employee.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("employee.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("employee.xml"))
    end
  end

  def test_get_employee
    # Make sure there is an employee in Xero to retrieve
    employee = @gateway.create_employee(dummy_employee).employee
    flunk "get_employee could not be tested because create_employee failed" if employee.nil?

    result = @gateway.get_employee_by_id(employee.employee_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.employee.first_name, employee.first_name
    assert_equal result.employee.last_name, employee.last_name
  end
end
