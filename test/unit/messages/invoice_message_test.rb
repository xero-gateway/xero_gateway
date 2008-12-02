require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class InvoiceMessageTest < Test::Unit::TestCase
  def setup
    @schema = LibXML::XML::Schema.document(LibXML::XML::Document.file(File.join(File.dirname(__FILE__), '../../xsd/create_invoice.xsd')))
  end
  
  # Tests that the XML generated from an invoice object validates against the Xero XSD
  def test_build_xml
    invoice = create_test_invoice
    
    message = XeroGateway::Messages::InvoiceMessage.build_xml(invoice)

    # Check that the document matches the XSD
    assert LibXML::XML::Parser.string(message).parse.validate_schema(@schema), "The XML document generated did not validate against the XSD"
  end
  
  # Tests that an invoice can be converted into XML that Xero can understand, and then converted back to an invoice
  def test_build_and_parse_xml
    invoice = create_test_invoice
    
    # Generate the XML message
    invoice_as_xml = XeroGateway::Messages::InvoiceMessage.build_xml(invoice)

    # Parse the XML message and retrieve the invoice element
    invoice_element = REXML::XPath.first(REXML::Document.new(invoice_as_xml), "/Invoice")

    # Build a new invoice from the XML
    result_invoice = XeroGateway::Messages::InvoiceMessage.from_xml(invoice_element)

    assert_equal(invoice, result_invoice)
  end
  
  
  private
  
  def create_test_invoice
    invoice = XeroGateway::Invoice.new(:invoice_type => "THE INVOICE TYPE")
    invoice.date = Time.now
    invoice.due_date = Time.now + 10
    invoice.invoice_number = "12345"
    invoice.reference = "MY REFERENCE FOR THIS INVOICE"
    invoice.includes_tax = false
    invoice.sub_total = BigDecimal.new("1000")
    invoice.total_tax = BigDecimal.new("125")
    invoice.total = BigDecimal.new("1125")
    
    invoice.contact = XeroGateway::Contact.new(:contact_id => 55555)
    invoice.contact.name = "CONTACT NAME"
    invoice.contact.address.address_type = "THE ADDRESS TYPE FOR THE CONTACT"
    invoice.contact.address.line_1 = "LINE 1 OF THE ADDRESS"
    invoice.contact.phone.number = "12345"
    
    invoice.line_items << XeroGateway::LineItem.new({
      :description => "A LINE ITEM",
      :account_code => "200",
      :unit_amount => BigDecimal.new("100"),
      :tax_amount => BigDecimal.new("12.5"),
      :line_amount => BigDecimal.new("125")
    })
    invoice
  end
end