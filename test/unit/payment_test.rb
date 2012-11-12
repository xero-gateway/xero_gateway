require File.join(File.dirname(__FILE__), '../test_helper.rb')

class PaymentTest < Test::Unit::TestCase

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


  private

  def create_test_payment
    XeroGateway::Payment.new.tap do |payment|
      payment.invoice_id        = "a99a9aaa-9999-99a9-9aa9-aaaaaa9a9999"
      payment.amount            = 100.0
      payment.date              = Time.now.beginning_of_day
      payment.reference         = "Invoice Payment"
      payment.code              = 200
    end
  end
end