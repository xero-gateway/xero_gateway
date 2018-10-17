require File.dirname(__FILE__) + '/../test_helper'

class EmailInvoiceTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_post).with {|client, url, params| url =~ /Email$/ }.returns("")
    end
  end

  def test_email_invoice
    result = @gateway.email_invoice(dummy_invoice.invoice_id)
    assert_equal true, result
  end
end
