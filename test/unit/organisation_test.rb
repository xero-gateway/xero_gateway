require File.join(File.dirname(__FILE__), '../test_helper.rb')

class OrganisationTest < Test::Unit::TestCase
  
  # Tests that an organisation can be converted into XML that Xero can understand, and then converted back to an organisation
  def test_build_and_parse_xml
    org = create_test_organisation
    
    # Generate the XML message
    org_as_xml = org.to_xml

    # Parse the XML message and retrieve the account element
    org_element = REXML::XPath.first(REXML::Document.new(org_as_xml), "/Organisation")

    # Build a new account from the XML
    result_org = XeroGateway::Organisation.from_xml(org_element)
    
    # Check the account details
    assert_equal org, result_org
  end
  
  
  private
  
  def create_test_organisation
    XeroGateway::Organisation.new.tap do |org|
      org.name          = "Demo Company (NZ)"
      org.legal_name    = "Demo Company (NZ)"
      org.pays_tax      = true
      org.version       = "NZ"
      org.base_currency = "NZD"
    end
  end
end