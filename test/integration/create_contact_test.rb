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
      @gateway.stubs(:http_post).with {|url, body, params| url =~ /contact$/ }.returns(get_file_as_string("contact.xml"))          
    end
  end
  
  def test_create_contact
    example_contact = dummy_contact.dup
    
    result = @gateway.create_contact(example_contact)
    assert_valid_contact_save_response(result, example_contact)
  end
  
  def test_create_from_contact
    example_contact = dummy_contact.dup
    
    contact = @gateway.build_contact(example_contact)
    result = contact.create
    assert_valid_contact_save_response(result, example_contact)
  end

  def test_update_from_contact
    example_contact = dummy_contact.dup
    
    contact = @gateway.build_contact(example_contact)
    contact.create # need to create first so we have a ContactID
    
    result = contact.update
    assert_valid_contact_save_response(result, example_contact)
  end
  
  def test_save_from_contact
    example_contact = dummy_contact.dup
    
    contact = @gateway.build_contact(example_contact)
    result = contact.save
    assert_valid_contact_save_response(result, example_contact)
  end    
  
  def test_create_contact_valid
    example_contact = dummy_contact.dup
    assert_equal true, example_contact.valid?, "contact is invalid - errors:\n\t#{example_contact.errors.map { | error | "#{error[0]} #{error[1]}"}.join("\n\t")}"
  end
  
  private
  
    def assert_valid_contact_save_response(result, example_contact)
      assert_kind_of XeroGateway::Response, result
      assert result.success?
      assert !result.contact.contact_id.nil?
      assert !result.request_xml.nil?
      assert !result.response_xml.nil?
      assert_equal result.contact.name, example_contact.name
      assert example_contact.contact_id =~ GUID_REGEX      
    end
end