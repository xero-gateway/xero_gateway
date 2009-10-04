require File.join(File.dirname(__FILE__), '../test_helper.rb')

class TaxRateTest < Test::Unit::TestCase
  
  # Tests that a tax rate can be converted into XML that Xero can understand, and then converted back to a tax rate
  def test_build_and_parse_xml
    tax_rate = create_test_tax_rate
    
    # Generate the XML message
    tax_rate_as_xml = tax_rate.to_xml

    # Parse the XML message and retrieve the account element
    tax_rate_element = REXML::XPath.first(REXML::Document.new(tax_rate_as_xml), "/TaxRate")

    # Build a new account from the XML
    result_tax_rate = XeroGateway::TaxRate.from_xml(tax_rate_element)
    
    # Check the account details
    assert_equal tax_rate, result_tax_rate
  end
  
  
  private
  
  def create_test_tax_rate
    returning XeroGateway::TaxRate.new do |tax_rate|
       tax_rate.name = "GST on Expenses"
       tax_rate.tax_type = "INPUT"
       tax_rate.can_apply_to_assets      = true
       tax_rate.can_apply_to_equity      = true
       tax_rate.can_apply_to_expenses    = true
       tax_rate.can_apply_to_liabilities = true
       tax_rate.can_apply_to_revenue     = false
       tax_rate.display_tax_rate         = 12.500
       tax_rate.effective_rate           = 12.500
    end
  end
end