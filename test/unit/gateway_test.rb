require File.join(File.dirname(__FILE__), '../test_helper.rb')

class GatewayTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
  end

  context "with error handling" do

    should "handle token expired" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("token_expired"), :code => "401"))

      assert_raises XeroGateway::OAuth::TokenExpired do
        @gateway.get_accounts
      end
    end

    should "handle invalid request tokens" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invalid_request_token"), :code => "401"))

      assert_raises XeroGateway::OAuth::TokenInvalid do
        @gateway.get_accounts
      end
    end

    should "handle invalid consumer key" do
     XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invalid_consumer_key"), :code => "401"))

      assert_raises XeroGateway::OAuth::TokenInvalid do
        @gateway.get_accounts
      end
    end

    should "handle rate limit exceeded" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("rate_limit_exceeded"), :code => "401"))

      assert_raises XeroGateway::OAuth::RateLimitExceeded do
        @gateway.get_accounts
      end
    end

    should "handle unknown errors" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("bogus_oauth_error"), :code => "401"))

      assert_raises XeroGateway::OAuth::UnknownError do
        @gateway.get_accounts
      end
    end

    should "handle ApiExceptions" do
      XeroGateway::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "400"))

      assert_raises XeroGateway::ApiException do
        @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end

    should "handle invoices not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::InvoiceNotFoundError do
        @gateway.get_invoice('unknown-invoice-id')
      end
    end

    should "handle bank transactions not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::BankTransactionNotFoundError do
        @gateway.get_bank_transaction('unknown-bank-transaction-id')
      end
    end

    should "handle credit notes not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::CreditNoteNotFoundError do
        @gateway.get_credit_note('unknown-credit-note-id')
      end
    end

    should "handle random root elements" do
      XeroGateway::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => "<RandomRootElement></RandomRootElement>", :code => "200"))

      assert_raises XeroGateway::UnparseableResponse do
        @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end

    should "handle no root element" do
      XeroGateway::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_file_as_string("no_certificates_registered"), :code => 400))

      assert_raises RuntimeError do
        response = @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end
  end

  def test_unknown_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/AN_INVALID_ID$/ }.returns(get_file_as_string("unknown_error.xml"))
    end

    result = @gateway.get_invoice("AN_INVALID_ID")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert !result.errors.first.type.nil?
    assert !result.errors.first.description.nil?
  end

  def test_object_not_found_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/UNKNOWN_INVOICE_NO$/ }.returns(get_file_as_string("invoice_not_found_error.xml"))
    end

    result = @gateway.get_invoice("UNKNOWN_INVOICE_NO")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert_equal "Xero.API.Library.Exceptions.ObjectDoesNotExistException", result.errors.first.type
    assert !result.errors.first.description.nil?
  end
end
