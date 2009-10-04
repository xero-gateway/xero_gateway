require File.dirname(__FILE__) + '/../test_helper'

class GetCurrenciesTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Currencies$/ }.returns(get_file_as_string("currencies.xml"))          
    end
  end
  
  def test_get_currencies
    result = @gateway.get_currencies
    assert result.success?
    assert !result.response_xml.nil?
    
    assert result.currencies.size > 0
    assert_equal XeroGateway::Currency, result.currencies.first.class
    assert_equal "NZD", result.currencies.first.code
  end
end