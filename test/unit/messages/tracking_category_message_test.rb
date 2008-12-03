require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class TrackingCategoryMessageTest < Test::Unit::TestCase
  # Tests that a tracking category can be converted into XML that Xero can understand, and then converted back to a tracking category
  def test_build_and_parse_xml
    tracking_category = create_test_tracking_category
    
    # Generate the XML message
    tracking_category_as_xml = XeroGateway::Messages::TrackingCategoryMessage.build_xml(tracking_category)

    # Parse the XML message and retrieve the tracking category element
    tracking_category_element = REXML::XPath.first(REXML::Document.new(tracking_category_as_xml), "/TrackingCategory")

    # Build a new tracking category from the XML
    result_tracking_category = XeroGateway::Messages::TrackingCategoryMessage.from_xml(tracking_category_element)
    
    # Check the tracking category details
    assert_equal tracking_category, result_tracking_category
  end
  
  
  private
  
  def create_test_tracking_category
    tracking_category = XeroGateway::TrackingCategory.new
    tracking_category.name = "REGION"
    tracking_category.options = ["NORTH", "SOUTH", "CENTRAL"]
    tracking_category
  end
end