require File.join(File.dirname(__FILE__), '../test_helper.rb')

class PaymentTest < Test::Unit::TestCase
  include TestHelper

  # Tests that a payment can be converted into XML that Xero can understand, and then converted back to a payment
  def test_build_and_parse_xml
    payment = create_test_payment

    # Generate the XML message
    payment_as_xml = payment.to_xml

    # Parse the XML message and retrieve the account element
    payment_element = REXML::XPath.first(REXML::Document.new(payment_as_xml), "/Payment")

    # Build a new account from the XML
    result_payment = XeroGateway::Payment.from_xml(payment_element)

    # Check the details
    assert_equal payment, result_payment
  end

  context "creating test payment" do
    should "create a test payment" do
      payment = create_test_payment

      assert_equal 'a99a9aaa-9999-99a9-9aa9-aaaaaa9a9999', payment.payment_id
      assert_equal 'ACCRECPAYMENT', payment.payment_type
      assert_equal Date.today.to_time, payment.date
      assert payment.updated_at.is_a? Time
      assert_equal 1000.0, payment.amount
      assert_equal '12345', payment.reference
      assert_equal 1.0, payment.currency_rate
      assert_equal 'i99i9iii-9999-99i9-9ii9-iiiiii9i9999', payment.invoice_id
      assert_equal 'INV-0001', payment.invoice_number
      assert_equal 'o99o9ooo-9999-99o9-9oo9-oooooo9o9999', payment.account_id
    end
  end

end
