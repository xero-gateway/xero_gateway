require File.dirname(__FILE__) + '/../test_helper'

class GetTrackingCategoriesTest < Test::Unit::TestCase
  include IntegrationTestMethods
  
  def setup
    @gateway = XeroGateway::Gateway.new(:customer_key => CUSTOMER_KEY, :api_key => API_KEY)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|url, params| url =~ /tracking$/ }.returns(get_file_as_string("tracking_categories.xml"))          
    end
  end
  
  def test_get_tracking_categories
    result = @gateway.get_tracking_categories
    assert result.success?
    if STUB_XERO_CALLS
      assert result.tracking_categories.size == 2
    end
  end
end