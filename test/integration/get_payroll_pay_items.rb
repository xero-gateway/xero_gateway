require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollPayItemsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /PayItems$/ }.returns(get_file_as_string("payroll_pay_items.xml"))
    end
  end

  def test_get_payroll_items
    result = @gateway.get_payroll_pay_items
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_not_equal(0, result.response_item)

    result.response_item.each do | pay_item |
      assert_not_equal pay_item.earnings_rates, []
      assert_not_equal pay_item.deduction_types, []
      assert_not_equal pay_item.reimbursement_types, []
      assert_not_equal pay_item.leave_types, []
      assert_equal pay_item.earnings_rates.size, 4
      assert_equal pay_item.deduction_types.size, 5
      assert_equal pay_item.reimbursement_types.size, 2
      assert_equal pay_item.earnings_rates.size, 9
    end
  end


  def test_get_earning_rate
    result = @gateway.get_payroll_pay_items
    result.response_item.earnings_rates do |earnings_rate|
      assert_not_equal earnings_rate.name, ""
      assert_not_equal earnings_rate.account_code, ""
      assert_not_equal earnings_rate.type_of_units, ""
      assert_not_equal earnings_rate.is_exempt_from_tax, ""
    end
  end

end
