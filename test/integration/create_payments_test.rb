require File.dirname(__FILE__) + '/../test_helper'

class CreatePaymentsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Invoices$/ }.returns(get_file_as_string("create_invoice.xml"))
      @gateway.stubs(:http_put).with {|client, url, params| url =~ /Payments$/ }.returns(get_file_as_string("create_payments.xml"))
    end
  end

  def test_create_payment
    example_invoice = dummy_invoice.dup

    result = @gateway.create_invoice(example_invoice)

    payment = XeroGateway::Payment.new(
      :invoice_id => result.invoice.invoice_id,
      :amount     => 500,
      :reference  => "Test Payment",
      :date       => Time.now,
      :code       => "601"
    )

    result = @gateway.create_payment(payment)

    assert_kind_of XeroGateway::Response, result
    assert result.success?
  end
end