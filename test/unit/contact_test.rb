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

  # this allows you to remove addresses from Xero
  test "explicity passing an empty array for addresses should include an empty element" do
    contact = create_test_contact
    contact.addresses = nil

    parsed = REXML::XPath.first(REXML::Document.new(contact.to_xml), "/Contact")
    assert !parsed.children.map(&:name).include?("Addresses")

    contact.addresses = []
    parsed = REXML::XPath.first(REXML::Document.new(contact.to_xml), "/Contact")
    assert parsed.children.map(&:name).include?("Addresses")
  end

  test "should be able to set addresses as part of initialize" do
    contact = XeroGateway::Contact.new(contact_id: "abcdef-3abe", name: "Test", addresses: [])

    parsed = REXML::XPath.first(REXML::Document.new(contact.to_xml), "/Contact")
    assert parsed.children.map(&:name).include?("Addresses")
  end

  test "parsing from XML" do
    test_xml = <<-TESTING.strip_heredoc.chomp
    <Contact>
      <ContactID>f1d403d1-7d30-46c2-a2be-fc2bb29bd295</ContactID>
      <ContactStatus>ACTIVE</ContactStatus>
      <Name>24 Locks</Name>
      <Addresses>
        <Address>
          <AddressType>POBOX</AddressType>
        </Address>
        <Address>
          <AddressType>STREET</AddressType>
        </Address>
      </Addresses>
      <Phones>
        <Phone>
          <PhoneType>DDI</PhoneType>
        </Phone>
        <Phone>
          <PhoneType>DEFAULT</PhoneType>
        </Phone>
        <Phone>
          <PhoneType>FAX</PhoneType>
        </Phone>
        <Phone>
          <PhoneType>MOBILE</PhoneType>
        </Phone>
      </Phones>
      <ContactPersons>
        <ContactPerson>
          <FirstName>John</FirstName>
          <LastName>Smith</LastName>
          <EmailAddress>john@acme.com</EmailAddress>
          <IncludeInEmails>true</IncludeInEmails>
        </ContactPerson>
      </ContactPersons>
      <UpdatedDateUTC>2016-08-31T04:55:39.217</UpdatedDateUTC>
      <IsSupplier>false</IsSupplier>
      <IsCustomer>false</IsCustomer>
      <HasAttachments>false</HasAttachments>
    </Contact>
    TESTING

    contact_element = REXML::XPath.first(REXML::Document.new(test_xml.gsub(/\s/, "")), "/Contact")
    contact = XeroGateway::Contact.from_xml(contact_element)

    assert_equal Time.utc(2016, 8, 31, 04, 55, 39), contact.updated_at.utc

  end

  # Test Contact#add_address helper creates a valid XeroGateway::Contact object with the passed in values
  # and appends it to the Contact#addresses attribute.
  def test_add_address_helper
    contact = create_test_contact
    assert_equal(1, contact.addresses.size)

    new_values = {
      :address_type => 'POBOX',
      :line_1 => 'NEW LINE 1',
      :line_2 => 'NEW LINE 2',
      :line_3 => 'NEW LINE 3',
      :line_4 => 'NEW LINE 4',
      :city => 'NEW CITY',
      :region => 'NEW REGION',
      :post_code => '5555',
      :country => 'Australia'
    }
    contact.add_address(new_values)

    assert_equal(2, contact.addresses.size)
    assert_kind_of(XeroGateway::Address, contact.addresses.last)
    new_values.each { |k,v| assert_equal(v, contact.addresses.last.send("#{k}")) }
  end

  # Test Contact#add_phone helper creates a valid XeroGateway::Phone object with the passed in values
  # and appends it to the Contact#phones attribute.
  def test_add_phone_helper
    contact = create_test_contact
    assert_equal(1, contact.phones.size)

    new_values = {
      :phone_type => 'MOBILE',
      :country_code => '61',
      :area_code => '406',
      :number => '123456'
    }
    contact.add_phone(new_values)

    assert_equal(2, contact.phones.size)
    assert_kind_of(XeroGateway::Phone, contact.phones.last)
    new_values.each { |k,v| assert_equal(v, contact.phones.last.send("#{k}")) }
  end

  def test_valid_phone_number
    phone = XeroGateway::Phone.new({
     :phone_type => 'MOBILE',
     :country_code => '61',
     :area_code => '406',
     :number => '0123456789'
    })
    assert(phone.valid?)
  end

  def test_invalid_phone_number
    phone = XeroGateway::Phone.new({
     :phone_type => 'MOBILE',
     :country_code => '61',
     :area_code => '406',
     :number => '012345678901234567890123456789012345678901234567890'
    })
    assert(!phone.valid?)
  end

  def test_loads_branding_theme_if_set
    test_xml = <<-TESTING.strip_heredoc.chomp
    <Contact>
      <ContactID>f1d403d1-7d30-46c2-a2be-fc2bb29bd295</ContactID>
      <ContactStatus>ACTIVE</ContactStatus>
      <Name>24 Locks</Name>
      <Addresses>
        <Address>
          <AddressType>POBOX</AddressType>
        </Address>
        <Address>
          <AddressType>STREET</AddressType>
        </Address>
      </Addresses>
      <Phones>
        <Phone>
          <PhoneType>DDI</PhoneType>
        </Phone>
        <Phone>
          <PhoneType>DEFAULT</PhoneType>
        </Phone>
        <Phone>
          <PhoneType>FAX</PhoneType>
        </Phone>
        <Phone>
          <PhoneType>MOBILE</PhoneType>
        </Phone>
      </Phones>
      <ContactPersons>
        <ContactPerson>
          <FirstName>John</FirstName>
          <LastName>Smith</LastName>
          <EmailAddress>john@acme.com</EmailAddress>
          <IncludeInEmails>true</IncludeInEmails>
        </ContactPerson>
      </ContactPersons>
      <UpdatedDateUTC>2016-08-31T04:55:39.217</UpdatedDateUTC>
      <IsSupplier>false</IsSupplier>
      <IsCustomer>false</IsCustomer>
      <HasAttachments>false</HasAttachments>
      <BrandingTheme>
        <BrandingThemeID>3761deb4-209e-4197-80bb-2993aff35387</BrandingThemeID>
        <Name>Test_Theme</Name>
      </BrandingTheme>
    </Contact>
    TESTING

    contact_element = REXML::XPath.first(REXML::Document.new(test_xml.gsub(/\s/, "")), "/Contact")
    contact = XeroGateway::Contact.from_xml(contact_element)

    assert_equal "Test_Theme", contact.branding_theme.name
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
    contact.is_customer = true
    contact.is_supplier = true
    contact.add_contact_person(first_name: 'John', last_name: 'Smith', email_address: 'john@acme.com', include_in_emails: true)

    contact
  end
end
