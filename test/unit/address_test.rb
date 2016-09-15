require File.join(File.dirname(__FILE__), '../test_helper.rb')

class AddressTest < Test::Unit::TestCase

  test "build and parse XML" do
    address = create_test_address

    # Generate the XML message
    address_xml = address.to_xml

    # Parse the XML message and retrieve the address element
    address_element = REXML::XPath.first(REXML::Document.new(address_xml), "/Address")

    # Build a new contact from the XML
    result_address = XeroGateway::Address.from_xml(address_element)

    # Check the contact details
    assert_equal address, result_address
  end

  private

    def create_test_address
      XeroGateway::Address.new(
        line_1:       "25 Taranaki St",
        line_2:       "Te Aro",
        city:         "Wellington",
        post_code:    "6011",
        country:      "New Zealand",
        attention_to: "Hashigo Zake"
      )
    end

end
