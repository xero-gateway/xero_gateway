require File.dirname(__FILE__) + '/../test_helper'

class GetAccountsTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Accounts$/ }.returns(get_file_as_string("accounts.xml"))          
    end
  end
  
  def test_get_accounts
    result = @gateway.get_accounts
    assert result.success?
    assert !result.response_xml.nil?
    assert result.accounts.size > 0
    assert_equal XeroGateway::Account, result.accounts.first.class
  end
end