require File.dirname(__FILE__) + '/../test_helper'

class GetContactTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Contacts\/[^\/]+$/ }.returns(get_file_as_string("contact.xml"))          
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Contacts$/ }.returns(get_file_as_string("contact.xml"))          
    end
  end
  
  def test_get_contact
    # Make sure there is an contact in Xero to retrieve
    contact = @gateway.create_contact(dummy_contact).contact
    flunk "get_contact could not be tested because create_contact failed" if contact.nil?

    result = @gateway.get_contact_by_id(contact.contact_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.contact.name, contact.name
  end
end