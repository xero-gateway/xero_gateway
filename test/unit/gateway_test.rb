require File.join(File.dirname(__FILE__), '../test_helper.rb')

class GatewayTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
  end
  
  def test_invalid_api_key_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoices$/ }.returns(get_file_as_string("invalid_api_key_error.xml"))          
    end

    @gateway.api_key = "AN_INVALID_API_KEY"
    
    result = @gateway.get_invoices
    assert !result.success?
    assert_equal "INVALID_API_KEY", result.status    
  end

  def test_invalid_customer_key_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoices$/ }.returns(get_file_as_string("invalid_customer_key_error.xml"))          
    end

    @gateway.customer_key = "AN_INVALID_CUSTOMER_KEY"

    result = @gateway.get_invoices

    assert !result.success?
    assert_equal 1, result.errors.size    
    assert result.errors.first.description =~ /^AN_INVALID_CUSTOMER_KEY is not a valid Xero authentication key/
  end
  
  def test_unknown_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoice$/ }.returns(get_file_as_string("unknown_error.xml"))          
    end
    
    result = @gateway.get_invoice_by_id("AN_INVALID_ID")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert !result.errors.first.type.nil?
    assert !result.errors.first.description.nil?
  end

  def test_object_not_found_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice_not_found_error.xml"))
    end
    
    result = @gateway.get_invoice_by_number("UNKNOWN_INVOICE_NO")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert_equal "Xero.API.Library.Exceptions.ObjectDoesNotExistException", result.errors.first.type
    assert !result.errors.first.description.nil?
  end
end