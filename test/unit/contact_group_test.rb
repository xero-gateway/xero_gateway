require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ContactGroupTest < Test::Unit::TestCase
  # Tests that a tracking category can be converted into XML that Xero can understand, and then converted back to a tracking category
  def test_build_and_parse_xml
    contact_group = create_test_contact_group
    
    # Generate the XML message
    contact_group_as_xml = contact_group.to_xml

    # Parse the XML message and retrieve the contact group element
    contact_group_element = REXML::XPath.first(REXML::Document.new(contact_group_as_xml), "/ContactGroup")

    # Build a new contact group from the XML
    result_contact_group = XeroGateway::ContactGroup.from_xml(contact_group_element, nil)
    
    # Check the tracking category details
    assert_equal contact_group.contact_group_id, result_contact_group.contact_group_id
    assert_equal contact_group.name, result_contact_group.name
    assert_equal contact_group.contact_ids, result_contact_group.contact_ids
    assert_equal contact_group.status, result_contact_group.status
  end

  def test_download_and_memoize_contacts_from_partial_load
    stub_contact_list = [stub(), stub()]
    contact_group = create_test_contact_group
    contact_group.gateway = stub()
    contact_group.gateway.expects(:get_contact_group_by_id).with(contact_group.contact_group_id).returns(
      stub(contact_group: stub(contacts: stub_contact_list))
    ).once

    assert_equal stub_contact_list, contact_group.contacts
    assert_equal stub_contact_list, contact_group.contacts, "Should not reload API call."
  end

  private

  def create_test_contact_group
    contact_group = XeroGateway::ContactGroup.new
    contact_group.contact_group_id = "abcd-efgh-ijkl-mnop-qrst-uvwx"
    contact_group.name = "My Group"
    contact_group.contact_ids = %w(abc def hij klm nop qrs)
    contact_group.status = "ACTIVE"
    contact_group
  end

end