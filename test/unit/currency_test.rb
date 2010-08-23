require File.join(File.dirname(__FILE__), '../test_helper.rb')

class CurrencyTest < Test::Unit::TestCase
  
  # Tests that a currency can be converted into XML that Xero can understand, and then converted back to a currency
  def test_build_and_parse_xml
    currency = create_test_currency
    
    # Generate the XML message
    currency_as_xml = currency.to_xml

    # Parse the XML message and retrieve the account element
    currency_element = REXML::XPath.first(REXML::Document.new(currency_as_xml), "/Currency")

    # Build a new account from the XML
    result_currency = XeroGateway::Currency.from_xml(currency_element)
    
    # Check the account details
    assert_equal currency, result_currency
  end
  
  
  private
  
  def create_test_currency
    XeroGateway::Currency.new.tap do |currency|
      currency.code        = "NZD"
      currency.description = "New Zealand Dollar"
    end
  end
end