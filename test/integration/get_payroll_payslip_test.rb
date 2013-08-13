require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollPayslipTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Payslip\/[^\/]+$/ }.returns(get_file_as_string("payroll_payslip.xml"))
    end
  end

  def test_get_payroll_payslip_test
    payslip_id = "a0051bf6-79a2-4e8c-a485-9f6ff671b3ac"
    result = @gateway.get_payroll_payslip_by_id(payslip_id)
    assert !result.request_params.nil?
    assert !result.response_xml.nil?

    assert_equal result.response_item.payslip_id, "p2d3f1bf6-79a2-4e8c-a485-9f6ff671b3ac"
    assert_equal result.response_item.employee_id, "x342d509-4d61-46f1-bb6c-f3c68c308a48"
    assert_equal result.response_item.first_name, "John"
    assert_equal result.response_item.last_name, "Smith"
    assert_equal result.response_item.tax_lines.length, 2
    assert_equal result.response_item.earnings_lines.length, 1
    assert_equal result.response_item.net_pay, '2000.30'
    assert_equal result.response_item.tax, '1000.00'
  end

  def test_get_payroll_earnings_lines_of_payslip_test
    payslip_id = "a0051bf6-79a2-4e8c-a485-9f6ff671b3ac"
    result = @gateway.get_payroll_payslip_by_id(payslip_id)
    assert_equal result.response_item.earnings_lines.first.earnings_rate_id, "a3d39287-631c-4da7-8362-04484a290493"
    assert_equal result.response_item.earnings_lines.first.rate_per_unit, "126.1716"
    assert_equal result.response_item.earnings_lines.first.number_of_units, "76.0000"
  end
end
