require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ItemTest < Test::Unit::TestCase

  # Tests that a item can be converted into XML that Xero can understand, and then converted back to a item
  def test_build_and_parse_xml
    item = create_test_item

    # Generate the XML message
    item_as_xml = item.to_xml

    # Parse the XML message and retrieve the account element
    item_element = REXML::XPath.first(REXML::Document.new(item_as_xml), "/Item")

    # Build a new account from the XML
    result_item = XeroGateway::Item.from_xml(item_element)

    # Check the account details
    assert_equal item, result_item
  end

  def test_load_item_xml
    xml_text = File.read("test/stub_responses/item.xml")
    xml_doc = REXML::Document.new(xml_text)
    xml = REXML::XPath.first(xml_doc, "/Item")

    item = XeroGateway::Item.from_xml(xml)

    assert_equal "19b79d12-0ae1-496e-9649-cbd04b15c7c5", item.item_id
    assert_equal "Merino-2011-LG", item.code
    assert_equal "Full Tracked Item", item.name
    assert_equal "2011 Merino Sweater - LARGE", item.description
    assert_equal "2011 Merino Sweater - LARGE", item.purchase_description
    assert_equal 149.0, item.purchase_details_unit_price
    assert_equal "300", item.purchase_details_account_code
    assert_equal 299.0, item.sales_details_unit_price
    assert_equal "200", item.sales_details_account_code
  end


  private

  def create_test_item
    XeroGateway::Item.new.tap do |item|
       item.code = "Merino-2011-LG"
       item.name = "Full Tracked Item"
       item.purchase_details_unit_price = 149.0
       item.purchase_details_account_code = "300"
    end
  end
end
