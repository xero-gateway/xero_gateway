require File.dirname(__FILE__) + '/../test_helper'

class CreateContactTest < Test::Unit::TestCase
  include IntegrationTestMethods
  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /contact$/ }.returns(get_file_as_string("contact.xml"))          
    end
  end
  
  def test_create_contact
    example_contact = dummy_contact
    
    result = @gateway.create_contact(example_contact)
    assert result.success?
    assert !result.contact.id.nil?
    assert_equal result.contact.name, example_contact.name
  end
end