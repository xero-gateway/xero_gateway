require File.join(File.dirname(__FILE__), '../test_helper.rb')

class GatewayTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  context "with oauth error handling" do
    
    should "handle token expired" do
      @gateway.stubs(:http_get).returns(get_file_as_string("token_expired"))
      
      assert_raises XeroGateway::OAuth::TokenExpired do
        @gateway.get_accounts
      end
    end
    
    should "handle invalid request tokens" do
      @gateway.stubs(:http_get).returns(get_file_as_string("invalid_request_token"))
      
      assert_raises XeroGateway::OAuth::TokenInvalid do
        @gateway.get_accounts
      end
    end
    
    should "handle invalid consumer key" do
      @gateway.stubs(:http_get).returns(get_file_as_string("invalid_consumer_key"))
      
      assert_raises XeroGateway::OAuth::TokenInvalid do
        @gateway.get_accounts
      end
    end
    
    should "handle ApiExceptions" do
      @gateway.stubs(:http_put).returns(get_file_as_string("api_exception.xml"))
      
      assert_raises XeroGateway::ApiException do
        @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end
    
    should "handle random root elements" do
      @gateway.stubs(:http_put).returns("<RandomRootElement></RandomRootElement>")
      
      assert_raises XeroGateway::UnparseableResponse do
        @gateway.create_invoice(XeroGateway::Invoice.new)
      end      
    end
    
  end
  
  def test_unknown_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/AN_INVALID_ID$/ }.returns(get_file_as_string("unknown_error.xml"))          
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
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Invoices$/ }.returns(get_file_as_string("invoice_not_found_error.xml"))
    end
    
    result = @gateway.get_invoice_by_number("UNKNOWN_INVOICE_NO")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert_equal "Xero.API.Library.Exceptions.ObjectDoesNotExistException", result.errors.first.type
    assert !result.errors.first.description.nil?
  end
end