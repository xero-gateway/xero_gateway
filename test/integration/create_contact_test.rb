require File.dirname(__FILE__) + '/../test_helper'

class CreateContactTest < Test::Unit::TestCase
  include TestHelper
  
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
    assert_kind_of XeroGateway::Response, result
    assert result.success?
    assert !result.contact.contact_id.nil?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?
    assert_equal result.contact.name, example_contact.name
    assert example_contact.contact_id =~ GUID_REGEX
  end
end