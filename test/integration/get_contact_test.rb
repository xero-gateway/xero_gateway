require File.dirname(__FILE__) + '/../test_helper'

class GetContactTest < Test::Unit::TestCase
  include IntegrationTestMethods
  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|url, params| url =~ /contact$/ }.returns(get_file_as_string("contact.xml"))          
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /contact$/ }.returns(get_file_as_string("contact.xml"))          
    end
  end
  
  def test_get_contact
    # Make sure there is a contact in Xero to retrieve
    contact = @gateway.create_contact(dummy_contact).contact
    
    result = @gateway.get_contact_by_id(contact.contact_id)
    assert result.success?
    assert_equal result.contact.name, contact.name

    result = @gateway.get_contact_by_number(contact.contact_number)
    assert result.success?
    assert_equal result.contact.name, contact.name
  end
end