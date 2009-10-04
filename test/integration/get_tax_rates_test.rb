require File.dirname(__FILE__) + '/../test_helper'

class GetTaxRatesTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /TaxRates$/ }.returns(get_file_as_string("tax_rates.xml"))          
    end
  end
  
  def test_get_tax_rates
    result = @gateway.get_tax_rates
    assert result.success?
    assert !result.response_xml.nil?
    
    assert result.tax_rates.size > 0
    assert_equal XeroGateway::TaxRate, result.tax_rates.first.class
    assert_equal "GST on Expenses", result.tax_rates.first.name
  end
end