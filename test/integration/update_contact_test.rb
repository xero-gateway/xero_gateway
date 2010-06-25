require File.dirname(__FILE__) + '/../test_helper'

class UpdateContactTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Contacts$/ }.returns(get_file_as_string("contact.xml"))          
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /Contacts$/ }.returns(get_file_as_string("contact.xml"))          
    end
  end
  
  def test_update_contact
    # Make sure there is a contact in Xero to retrieve
    contact = @gateway.create_contact(dummy_contact).contact

    contact.phone.number = "123 4567"
    
    result = @gateway.update_contact(contact)

    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?    
    assert_equal contact.contact_id, result.contact.contact_id
    assert_equal "123 4567", result.contact.phone.number if !STUB_XERO_CALLS
  end
end