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

  def test_organisation_with_addresses
    org = create_test_organisation
    org.add_address(
      :address_type => 'POBOX',
      :line_1 => 'NEW LINE 1',
      :line_2 => 'NEW LINE 2',
      :line_3 => 'NEW LINE 3',
      :line_4 => 'NEW LINE 4',
      :city => 'NEW CITY',
      :region => 'NEW REGION',
      :post_code => '5555',
      :country => 'Australia'
    )

    org_as_xml = org.to_xml

    assert org_as_xml.include?("<Addresses><Address>")
    assert org_as_xml.include?("NEW REGION")

    org_element = REXML::XPath.first(REXML::Document.new(org_as_xml), "/Organisation")
    result_org = XeroGateway::Organisation.from_xml(org_element)

    assert_equal org, result_org
  end

  test "should raise if you add an unsupported type as an address" do
    org = create_test_organisation
    org.addresses = [ { :a => 123 }]

    assert_raises "UnsupportedAttributeType" do
      org.to_xml
    end
  end

  test "works with an empty addresses attribute" do
    org = create_test_organisation
    org.addresses = []

    assert org_as_xml = org.to_xml

    org_element = REXML::XPath.first(REXML::Document.new(org_as_xml), "/Organisation")
    result_org = XeroGateway::Organisation.from_xml(org_element)

    assert_equal org, result_org
  end

  private

  def create_test_organisation
    XeroGateway::Organisation.new.tap do |org|
      org.name                = "Demo Company (NZ)"
      org.legal_name          = "Demo Company (NZ)"
      org.pays_tax            = true
      org.version             = "NZ"
      org.base_currency       = "NZD"
      org.country_code        = "NZ"
      org.organisation_type   = nil
      org.organisation_status = nil
      org.is_demo_company     = false
      org.line_of_business = "Graphic Design & Web Development"
    end
  end
end
