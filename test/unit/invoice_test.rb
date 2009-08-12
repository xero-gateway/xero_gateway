require File.join(File.dirname(__FILE__), '../test_helper.rb')

class InvoiceTest < Test::Unit::TestCase
  
  def setup
    @schema = LibXML::XML::Schema.document(LibXML::XML::Document.file(File.join(File.dirname(__FILE__), '../xsd/create_invoice.xsd')))
  end
  
  # Tests that the XML generated from an invoice object validates against the Xero XSD
  def test_build_xml
    invoice = create_test_invoice
    
    message = invoice.to_xml

    # Check that the document matches the XSD
    assert LibXML::XML::Parser.string(message).parse.validate_schema(@schema), "The XML document generated did not validate against the XSD"
  end
  
  # Tests that an invoice can be converted into XML that Xero can understand, and then converted back to an invoice
  def test_build_and_parse_xml
    invoice = create_test_invoice
    
    # Generate the XML message
    invoice_as_xml = invoice.to_xml

    # Parse the XML message and retrieve the invoice element
    invoice_element = REXML::XPath.first(REXML::Document.new(invoice_as_xml), "/Invoice")

    # Build a new invoice from the XML
    result_invoice = XeroGateway::Invoice.from_xml(invoice_element)

    assert_equal(invoice, result_invoice)
  end
  
  # Tests the sub_total calculation and that setting it manually doesn't modify the data.
  def test_invoice_sub_total_calculation
    invoice = create_test_invoice
    line_item = invoice.line_items.first
    
    # Make sure that everything adds up to begin with.
    expected_sub_total = invoice.line_items.inject(BigDecimal.new('0')) { | sum, line_item | line_item.line_amount }
    assert_equal(expected_sub_total, invoice.sub_total)
    
    # Change the sub_total and check that it doesn't modify anything.
    invoice.sub_total = expected_sub_total * 10
    assert_equal(expected_sub_total, invoice.sub_total)
    
    # Change the amount of the first line item and make sure that 
    # everything still continues to add up.
    line_item.unit_amount = line_item.unit_amount + 10
    assert_not_equal(expected_sub_total, invoice.sub_total)
    expected_sub_total = invoice.line_items.inject(BigDecimal.new('0')) { | sum, line_item | line_item.line_amount }
    assert_equal(expected_sub_total, invoice.sub_total)
  end
  
  # Tests the total_tax calculation and that setting it manually doesn't modify the data.
  def test_invoice_sub_total_calculation
    invoice = create_test_invoice
    line_item = invoice.line_items.first
    
    # Make sure that everything adds up to begin with.
    expected_total_tax = invoice.line_items.inject(BigDecimal.new('0')) { | sum, line_item | line_item.tax_amount }
    assert_equal(expected_total_tax, invoice.total_tax)
    
    # Change the total_tax and check that it doesn't modify anything.
    invoice.total_tax = expected_total_tax * 10
    assert_equal(expected_total_tax, invoice.total_tax)
    
    # Change the tax_amount of the first line item and make sure that 
    # everything still continues to add up.
    line_item.tax_amount = line_item.tax_amount + 10
    assert_not_equal(expected_total_tax, invoice.total_tax)
    expected_total_tax = invoice.line_items.inject(BigDecimal.new('0')) { | sum, line_item | line_item.tax_amount }
    assert_equal(expected_total_tax, invoice.total_tax)
  end

  # Tests the total calculation and that setting it manually doesn't modify the data.
  def test_invoice_sub_total_calculation
    invoice = create_test_invoice
    line_item = invoice.line_items.first
    
    # Make sure that everything adds up to begin with.
    expected_total = invoice.sub_total + invoice.total_tax
    assert_equal(expected_total, invoice.total)
    
    # Change the total and check that it doesn't modify anything.
    invoice.total = expected_total * 10
    assert_equal(expected_total, invoice.total)
    
    # Change the quantity of the first line item and make sure that 
    # everything still continues to add up.
    line_item.quantity = line_item.quantity + 5
    assert_not_equal(expected_total, invoice.total)
    expected_total = invoice.sub_total + invoice.total_tax
    assert_equal(expected_total, invoice.total)
  end

  # Tests that the LineItem#line_amount calculation is working correctly.
  def test_line_amount_calculation
    invoice = create_test_invoice
    line_item = invoice.line_items.first
    
    # Make sure that everything adds up to begin with.
    expected_amount = line_item.quantity * line_item.unit_amount
    assert_equal(expected_amount, line_item.line_amount)
    
    # Change the line_amount and check that it doesn't modify anything.
    line_item.line_amount = expected_amount * 10
    assert_equal(expected_amount, line_item.line_amount)
    
    # Change the quantity and check that the line_amount has been updated.
    quantity = line_item.quantity + 2
    line_item.quantity = quantity
    assert_not_equal(expected_amount, line_item.line_amount)
    assert_equal(quantity * line_item.unit_amount, line_item.line_amount)
  end
  
  # Ensure that the totalling methods don't raise exceptions, even when
  # invoice.line_items is empty.
  def test_totalling_methods_when_line_items_empty
    invoice = create_test_invoice
    invoice.line_items = []
    
    assert_nothing_raised(Exception) {
      assert_equal(BigDecimal.new('0'), invoice.sub_total)
      assert_equal(BigDecimal.new('0'), invoice.total_tax)
      assert_equal(BigDecimal.new('0'), invoice.total)
    }
  end
  
  
  private
    
  def create_test_invoice
    invoice = XeroGateway::Invoice.new(:invoice_type => "THE INVOICE TYPE")
    invoice.date = Time.now
    invoice.due_date = Time.now + 10
    invoice.invoice_number = "12345"
    invoice.reference = "MY REFERENCE FOR THIS INVOICE"
    invoice.includes_tax = false
    
    invoice.contact = XeroGateway::Contact.new(:contact_id => 55555)
    invoice.contact.name = "CONTACT NAME"
    invoice.contact.address.address_type = "THE ADDRESS TYPE FOR THE CONTACT"
    invoice.contact.address.line_1 = "LINE 1 OF THE ADDRESS"
    invoice.contact.phone.number = "12345"
    
    invoice.line_items << XeroGateway::LineItem.new({
      :description => "A LINE ITEM",
      :account_code => "200",
      :unit_amount => BigDecimal.new("100"),
      :tax_amount => BigDecimal.new("12.5")
    })
    invoice
  end
end