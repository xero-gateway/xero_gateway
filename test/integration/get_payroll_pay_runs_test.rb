require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollPayRunsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /PayRuns$/ }.returns(get_file_as_string("payroll_pay_runs.xml"))
    end
  end

  def test_get_payroll_pay_run
    result = @gateway.get_payroll_pay_runs
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_not_equal(0, result.response_item)

    result.response_item.each do | pay_run |
      assert_not_equal pay_run.pay_run_id, ''
      assert_not_equal pay_run.tax, ''
      assert_not_equal pay_run.deductions, ''
      assert_not_equal pay_run.wages, ''
      assert_not_equal pay_run.reimbursement, ''
    end
  end

end
