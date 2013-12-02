require File.join(File.dirname(__FILE__), '../test_helper.rb')

class InvoiceTest < Test::Unit::TestCase

  context "with line item totals" do

    should "allow setting and reading these as instance variables without downloading line items" do
      invoice = create_test_invoice(:line_items_downloaded => false, :total => 6969_00)

      assert !invoice.line_items_downloaded?
      XeroGateway::Invoice.any_instance.expects(:download_line_items).never
      assert_equal 6969_00, invoice.total
    end
  end

  context "building and parsing XML" do
    should "work vice versa" do
      invoice = create_test_invoice

      # Generate the XML message
      invoice_as_xml = invoice.to_xml

      # Parse the XML message and retrieve the invoice element
      invoice_element = REXML::XPath.first(REXML::Document.new(invoice_as_xml), "/Invoice")

      # Build a new invoice from the XML
      result_invoice = XeroGateway::Invoice.from_xml(invoice_element)

      assert_equal(invoice, result_invoice)
    end

    should "work for optional params" do
      invoice = create_test_invoice(:url => 'http://example.com?with=params&and=more')
      invoice_element = REXML::XPath.first(REXML::Document.new(invoice.to_xml), "/Invoice")
      assert_match /<Url>http:\/\/example.com\?with=params&amp;and=more<\/Url>/, invoice_element.to_s

      parsed_invoice = XeroGateway::Invoice.from_xml(invoice_element)
      assert_equal 'http://example.com?with=params&and=more', parsed_invoice.url
    end
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
    invoice = create_test_invoice(:line_items_downloaded => true)
    assert invoice.line_items_downloaded?
    line_item = invoice.line_items.first
    
    # Make sure that everything adds up to begin with.
    expected_total = invoice.sub_total + invoice.total_tax
    assert_equal(expected_total, invoice.total)
    
    # Change the total and check that it doesn't modify anything.
    invoice.total = expected_total * 10
    assert_equal(expected_total.to_f, invoice.total.to_f)
    
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
  
  def test_invoice_type_helper_methods
    # Test accounts receivable invoices.
    invoice = create_test_invoice({:invoice_type => 'ACCREC'})
    assert_equal(true,  invoice.accounts_receivable?, "Accounts RECEIVABLE invoice doesn't think it is.")
    assert_equal(false, invoice.accounts_payable?,    "Accounts RECEIVABLE invoice thinks it's payable.")
    
    # Test accounts payable invoices.
    invoice = create_test_invoice({:invoice_type => 'ACCPAY'})
    assert_equal(false, invoice.accounts_receivable?, "Accounts PAYABLE invoice doesn't think it is.")
    assert_equal(true,  invoice.accounts_payable?,    "Accounts PAYABLE invoice thinks it's receivable.")
  end
  
  
  # Make sure that the create_test_invoice method is working correctly
  # with all the defaults and overrides.
  def test_create_test_invoice_defaults_working
    invoice = create_test_invoice
    
    # Test invoice defaults.
    assert_equal('ACCREC', invoice.invoice_type)
    assert_kind_of(Date, invoice.date)
    assert_kind_of(Date, invoice.due_date)
    assert_equal('12345', invoice.invoice_number)
    assert_equal('MY REFERENCE FOR THIS INVOICE', invoice.reference)
    assert_equal("Exclusive", invoice.line_amount_types)
    
    # Test the contact defaults.
    assert_equal('00000000-0000-0000-0000-000000000000', invoice.contact.contact_id)
    assert_equal('CONTACT NAME', invoice.contact.name)
    
    # Test address defaults.
    assert_equal('DEFAULT', invoice.contact.address.address_type)
    assert_equal('LINE 1 OF THE ADDRESS', invoice.contact.address.line_1)
    
    # Test phone defaults.
    assert_equal('DEFAULT', invoice.contact.phone.phone_type)
    assert_equal('12345678', invoice.contact.phone.number)
    
    # Test the line_item defaults.
    assert_equal('A LINE ITEM', invoice.line_items.first.description)
    assert_equal('200', invoice.line_items.first.account_code)
    assert_equal(BigDecimal.new('100'), invoice.line_items.first.unit_amount)
    assert_equal(BigDecimal.new('12.5'), invoice.line_items.first.tax_amount)

    # Test optional params
    assert_nil invoice.url

    # Test overriding an invoice parameter (assume works for all).
    invoice = create_test_invoice({:invoice_type => 'ACCPAY'})
    assert_equal('ACCPAY', invoice.invoice_type)
    
    # Test overriding a contact/address/phone parameter (assume works for all).
    invoice = create_test_invoice({}, {:name => 'OVERRIDDEN NAME', :address => {:line_1 => 'OVERRIDDEN LINE 1'}, :phone => {:number => '999'}})
    assert_equal('OVERRIDDEN NAME', invoice.contact.name)
    assert_equal('OVERRIDDEN LINE 1', invoice.contact.address.line_1)
    assert_equal('999', invoice.contact.phone.number)
    
    # Test overriding line_items with hash.
    invoice = create_test_invoice({}, {}, {:description => 'OVERRIDDEN LINE ITEM'})
    assert_equal(1, invoice.line_items.size)
    assert_equal('OVERRIDDEN LINE ITEM', invoice.line_items.first.description)
    assert_equal(BigDecimal.new('100'), invoice.line_items.first.unit_amount)
    
    # Test overriding line_items with array of 2 line_items.
    invoice = create_test_invoice({}, {}, [
      {:description => 'OVERRIDDEN ITEM 1'},
      {:description => 'OVERRIDDEN ITEM 2', :account_code => '200', :unit_amount => BigDecimal.new('200'), :tax_amount => '25.0'}
    ])
    assert_equal(2, invoice.line_items.size)
    assert_equal('OVERRIDDEN ITEM 1', invoice.line_items[0].description)
    assert_equal(BigDecimal.new('100'), invoice.line_items[0].unit_amount)
    assert_equal('OVERRIDDEN ITEM 2', invoice.line_items[1].description)
    assert_equal(BigDecimal.new('200'), invoice.line_items[1].unit_amount)
  end
  
  def test_auto_creation_of_associated_contact
    invoice = create_test_invoice({}, nil) # no contact
    assert_nil(invoice.instance_variable_get("@contact"))
    
    new_contact = invoice.contact
    assert_kind_of(XeroGateway::Contact, new_contact)
  end
  
  def test_add_line_item
    invoice = create_test_invoice({}, {}, nil) # no line_items
    assert_equal(0, invoice.line_items.size)
    
    line_item_params = {:description => "Test Item 1", :unit_amount => 100}
    
    # Test adding line item by hash
    line_item = invoice.add_line_item(line_item_params)
    assert_kind_of(XeroGateway::LineItem, line_item)
    assert_equal(line_item_params[:description], line_item.description)
    assert_equal(line_item_params[:unit_amount], line_item.unit_amount)
    assert_equal(1, invoice.line_items.size)
    
    # Test adding line item by XeroGateway::LineItem
    line_item = invoice.add_line_item(line_item_params)
    assert_kind_of(XeroGateway::LineItem, line_item)
    assert_equal(line_item_params[:description], line_item.description)
    assert_equal(line_item_params[:unit_amount], line_item.unit_amount)
    assert_equal(2, invoice.line_items.size)

    # Test that pushing anything else into add_line_item fails.
    ["invalid", 100, nil, []].each do | invalid_object |
      assert_raise(XeroGateway::InvalidLineItemError) { invoice.add_line_item(invalid_object) }
      assert_equal(2, invoice.line_items.size)
    end
  end

  def test_instantiate_invoice_with_default_line_amount_types
    invoice = XeroGateway::Invoice.new
    assert_equal(invoice.line_amount_types, 'Exclusive')
  end

  def test_optional_params
    invoice = create_test_invoice(:url => 'http://example.com', :branding_theme_id => 'a94a78db-5cc6-4e26-a52b-045237e56e6e')
    assert_equal 'http://example.com', invoice.url
    assert_equal 'a94a78db-5cc6-4e26-a52b-045237e56e6e', invoice.branding_theme_id
  end

  private
    
  def create_test_invoice(invoice_params = {}, contact_params = {}, line_item_params = [])
    unless invoice_params.nil?
      invoice_params = {
        :invoice_type => 'ACCREC',
        :date => Date.today,
        :due_date => Date.today + 10, # 10 days in the future
        :invoice_number => '12345',
        :reference => "MY REFERENCE FOR THIS INVOICE",
        :line_amount_types => "Exclusive"
      }.merge(invoice_params)
    end
    invoice = XeroGateway::Invoice.new(invoice_params || {})
    
    unless contact_params.nil?
      # Strip out :address key from contact_params to use as the default address.
      stripped_address = {
        :address_type => 'DEFAULT',
        :line_1 => 'LINE 1 OF THE ADDRESS'
      }.merge(contact_params.delete(:address) || {})
    
      # Strip out :phone key from contact_params to use at the default phone.
      stripped_phone = {
        :phone_type => 'DEFAULT',
        :number => '12345678'
      }.merge(contact_params.delete(:phone) || {})
    
      contact_params = {
        :contact_id => '00000000-0000-0000-0000-000000000000', # Just any valid GUID
        :name => "CONTACT NAME",
        :first_name => "Bob",
        :last_name => "Builder"
      }.merge(contact_params)
    
      # Create invoice.contact from contact_params.
      invoice.contact = XeroGateway::Contact.new(contact_params)
      invoice.contact.address = XeroGateway::Address.new(stripped_address)
      invoice.contact.phone = XeroGateway::Phone.new(stripped_phone)
    end
    
    unless line_item_params.nil?
      line_item_params = [line_item_params].flatten # always use an array, even if only a single hash passed in
    
      # At least one line item, make first have some defaults.
      line_item_params << {} if line_item_params.size == 0
      line_item_params[0] = {
        :description => "A LINE ITEM",
        :account_code => "200",
        :unit_amount => BigDecimal.new("100"),
        :tax_amount => BigDecimal.new("12.5"),
        :tracking => XeroGateway::TrackingCategory.new(:name => "blah", :options => "hello")
      }.merge(line_item_params[0])
    
      # Create invoice.line_items from line_item_params
      line_item_params.each do | line_item |
        invoice.add_line_item(line_item)
      end
    end
    
    invoice
  end

  # NB: Xero no longer appears to provide XSDs for their api, check http://blog.xero.com/developer/api/invoices/
  #
  # context "validating against the Xero XSD" do
  #   setup do
  #     # @schema = LibXML::XML::Schema.document(LibXML::XML::Document.file(File.join(File.dirname(__FILE__), '../xsd/create_invoice.xsd')))
  #   end
  #
  #   should "succeed" do
  #     invoice = create_test_invoice
  #     message = invoice.to_xml
  #
  #     # Check that the document matches the XSD
  #     assert LibXML::XML::Parser.string(message).parse.validate_schema(@schema), "The XML document generated did not validate against the XSD"
  #   end
  # end

end
