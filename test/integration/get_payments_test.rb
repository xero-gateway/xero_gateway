require File.dirname(__FILE__) + '/../test_helper'

class GetPaymentsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Payments(\/[0-9a-z\-]+)?$/i }.returns(get_file_as_string("payments.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Payments$/ }.returns(get_file_as_string("create_payments.xml"))
    end
  end

  def test_get_payments
    # Make sure there is a bank transaction in Xero to retrieve
    payment = @gateway.create_payment(create_test_payment).payments

    result = @gateway.get_payments
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.payments.collect {|i| i.reference}.include?(payment.first.reference)
    assert result.payments.collect {|i| i.payment_id}.include?(payment.first.payment_id)
    assert_kind_of(XeroGateway::Payment, payment.first)
  end

  def test_get_payments_modified_since_date
    # Create a test payment
    @gateway.create_payment(create_test_payment)

    # Check that it is returned
    result = @gateway.get_payments(:modified_since => Date.today - 1)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.request_params.keys.include?(:ModifiedAfter) # make sure the flag was sent
  end

  def test_get_payments_find_by_id
    # Create a test payment
    @gateway.create_payment(create_test_payment)

    # Check that it is returned
    result = @gateway.get_payments(:payment_id => create_test_payment.payment_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.request_params.keys.include?(:PaymentID) # make sure the flag was sent
  end

end
