require File.dirname(__FILE__) + '/../test_helper'

class GetContactsTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Contacts$/ }.returns(get_file_as_string("contacts.xml"))          
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Contacts$/ }.returns(get_file_as_string("contact.xml"))          
    end
  end
  
  def test_get_contacts
    # Make sure there is an contact in Xero to retrieve
    contact = @gateway.create_contact(dummy_contact).contact
    flunk "get_contacts could not be tested because create_contact failed" if contact.nil?

    result = @gateway.get_contacts
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.contacts.collect {|c| c.contact_id}.include?(contact.contact_id)
  end  
  
  # Make sure that a reference to gateway is passed when the get_contacts response is parsed.
  def test_get_contacts_gateway_reference
    result = @gateway.get_contacts
    assert(result.success?)
    assert_not_equal(0, result.contacts.size)
    
    result.contacts.each do | contact |
      assert(contact.gateway === @gateway)
    end
  end
  
end