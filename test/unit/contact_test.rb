require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ContactTest < Test::Unit::TestCase
  def setup
    @schema = LibXML::XML::Schema.document(LibXML::XML::Document.file(File.join(File.dirname(__FILE__), '../xsd/create_contact.xsd')))
  end
  
  # Tests that the XML generated from a contact object validates against the Xero XSD
  def test_build_xml
    contact = create_test_contact
    
    message = contact.to_xml

    # Check that the document matches the XSD
    assert LibXML::XML::Parser.string(message).parse.validate_schema(@schema), "The XML document generated did not validate against the XSD"
  end
  
  # Tests that a contact can be converted into XML that Xero can understand, and then converted back to a contact
  def test_build_and_parse_xml
    contact = create_test_contact
    
    # Generate the XML message
    contact_as_xml = contact.to_xml

    # Parse the XML message and retrieve the contact element
    contact_element = REXML::XPath.first(REXML::Document.new(contact_as_xml), "/Contact")

    # Build a new contact from the XML
    result_contact = XeroGateway::Contact.from_xml(contact_element)
    
    # Check the contact details
    assert_equal contact, result_contact
  end
  
  
  private
  
  def create_test_contact
    contact = XeroGateway::Contact.new(:contact_id => "55555")
    contact.contact_number = "aaa111"
    contact.name = "CONTACT NAME"
    contact.email = "someone@somewhere.com"
    contact.address.address_type = "THE ADDRESS TYPE FOR THE CONTACT"
    contact.address.line_1 = "LINE 1 OF THE ADDRESS"
    contact.address.line_2 = "LINE 2 OF THE ADDRESS"
    contact.address.line_3 = "LINE 3 OF THE ADDRESS"
    contact.address.line_4 = "LINE 4 OF THE ADDRESS"
    contact.phone.number = "12345"

    contact
  end
end