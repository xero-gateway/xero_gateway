require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollSuperFundsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /SuperFunds$/ }.returns(get_file_as_string("payroll_super_funds.xml"))
    end
  end

  def test_get_payroll_super_funds_gateway_reference
    result = @gateway.get_payroll_super_funds

    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_not_equal(0, result.response_item.size)

    result.response_item.each do | super_fund |
      assert_not_equal super_fund.super_fund_id, ''
      assert_not_equal super_fund.type, ''
      assert_not_equal super_fund.name, ''
      assert_not_equal super_fund.abn, ''
      assert_not_equal super_fund.bsb, ''
      assert_not_equal super_fund.account_number, ''
      assert_not_equal super_fund.account_name, ''
    end
  end

end