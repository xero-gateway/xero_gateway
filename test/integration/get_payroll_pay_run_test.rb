require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollPayRunTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /PayRun\/[^\/]+$/ }.returns(get_file_as_string("payroll_pay_run.xml"))
    end
  end

  def test_get_payroll_pay_run_test
    pay_run_id = "11111111-da28-4ee8-9c83-4eea9dd09311"
    result = @gateway.get_payroll_pay_run_by_id(pay_run_id)
    assert !result.request_params.nil?
    assert !result.response_xml.nil?

    assert_equal result.response_item.pay_run_id, "11111111-da28-4ee8-9c83-4eea9dd09311"
    assert_equal result.response_item.payslips.first.employee_id, "55555555-4d61-46f1-bb6c-f3c68c308a48"
    assert_equal result.response_item.tax, "2222.00"
    assert_equal result.response_item.pay_run_status,'DRAFT'
    assert_equal result.response_item.wages, "1111.30"
    assert_equal result.response_item.deductions, '0.00'
    assert_equal result.response_item.net_pay, "4444.30"
    assert_equal result.response_item.super, '333.50'
    assert_equal result.response_item.reimbursement, '0.00'
  end
end
