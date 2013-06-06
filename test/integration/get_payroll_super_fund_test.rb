require File.dirname(__FILE__) + '/../test_helper'

class GetPayrollSuperFundTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_payroll_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /SuperFunds$/ }.returns(get_file_as_string("payroll_super_funds.xml"))
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /SuperFunds\/[^\/]+$/ }.returns(get_file_as_string("payroll_super_fund.xml"))
    end
  end

  def test_payroll_get_super_fund
    # Make sure there is an super_fund in Xero to retrieve
    super_funds = @gateway.get_payroll_super_funds.response_item
    
    result = @gateway.get_payroll_super_fund_by_id(super_funds.first.super_fund_id)
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.response_item.type, "SMSF"
    assert_equal result.response_item.name, "Clive Monk Superannuation Fund"
    assert_equal result.response_item.abn, "11001032511"
    assert_equal result.response_item.bsb, "159357"
    assert_equal result.response_item.account_name, "Test"
    assert_equal result.response_item.account_number, "111222333"
  end
end
