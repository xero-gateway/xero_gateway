require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollLeaveApplicationsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /LeaveApplications$/ }.returns(get_file_as_string("payroll_leave_applications.xml"))
    end
  end

  def test_get_payroll_leave_applications
    result = @gateway.get_payroll_leave_applications
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_not_equal(0, result.response_item)

    result.response_item.each do | leave_application |
      assert_not_equal leave_application.leave_type_id, ''
      assert_not_equal leave_application.title, ''
      assert_not_equal leave_application.start_date, ''
      assert_not_equal leave_application.end_date, ''
      assert_not_equal leave_application.leave_periods, ''
    end
  end

end