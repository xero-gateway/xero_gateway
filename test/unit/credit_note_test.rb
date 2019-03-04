require File.join(File.dirname(__FILE__), '../test_helper.rb')

class CreditNoteTest < Test::Unit::TestCase

  # Tests that a credit note can be converted into XML that Xero can understand, and then converted back to a credit note
  def test_build_and_parse_xml
    credit_note = create_test_credit_note

    # Generate the XML message
    credit_note_as_xml = credit_note.to_xml

    # Parse the XML message and retrieve the credit_note element
    credit_note_element = REXML::XPath.first(REXML::Document.new(credit_note_as_xml), "/CreditNote")

    # Build a new credit_note from the XML
    result_credit_note = XeroGateway::CreditNote.from_xml(credit_note_element)

    assert_equal(credit_note, result_credit_note)
  end

  # Tests the sub_total calculation and that setting it manually doesn't modify the data.
  def test_credit_note_sub_total_calculation
    credit_note = create_test_credit_note
    line_item = credit_note.line_items.first

    # Make sure that everything adds up to begin with.
    expected_sub_total = credit_note.line_items.inject(BigDecimal('0')) { | sum, l | l.line_amount }
    assert_equal(expected_sub_total, credit_note.sub_total)

    # Change the amount of the first line item and make sure that
    # everything still continues to add up.
    line_item.unit_amount = line_item.unit_amount + 10
    assert_not_equal(expected_sub_total, credit_note.sub_total)
    expected_sub_total = credit_note.line_items.inject(BigDecimal('0')) { | sum, l | l.line_amount }
    assert_equal(expected_sub_total, credit_note.sub_total)
  end

  # Tests the total_tax calculation and that setting it manually doesn't modify the data.
  def test_credit_note_sub_total_calculation2
    credit_note = create_test_credit_note
    line_item = credit_note.line_items.first

    # Make sure that everything adds up to begin with.
    expected_total_tax = credit_note.line_items.inject(BigDecimal('0')) { | sum, l | l.tax_amount }
    assert_equal(expected_total_tax, credit_note.total_tax)

    # Change the tax_amount of the first line item and make sure that
    # everything still continues to add up.
    line_item.tax_amount = line_item.tax_amount + 10
    assert_not_equal(expected_total_tax, credit_note.total_tax)
    expected_total_tax = credit_note.line_items.inject(BigDecimal('0')) { | sum, l | l.tax_amount }
    assert_equal(expected_total_tax, credit_note.total_tax)
  end

  # Tests the total calculation and that setting it manually doesn't modify the data.
  def test_credit_note_sub_total_calculation3
    credit_note = create_test_credit_note
    line_item = credit_note.line_items.first

    # Make sure that everything adds up to begin with.
    expected_total = credit_note.sub_total + credit_note.total_tax
    assert_equal(expected_total, credit_note.total)

    # Change the quantity of the first line item and make sure that
    # everything still continues to add up.
    line_item.quantity = line_item.quantity + 5
    assert_not_equal(expected_total, credit_note.total)
    expected_total = credit_note.sub_total + credit_note.total_tax
    assert_equal(expected_total, credit_note.total)
  end

  # Tests that the LineItem#line_amount calculation is working correctly.
  def test_line_amount_calculation
    credit_note = create_test_credit_note
    line_item = credit_note.line_items.first

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
  # credit_note.line_items is empty.
  def test_totalling_methods_when_line_items_empty
    credit_note = create_test_credit_note
    credit_note.line_items = []

    assert_nothing_raised(Exception) {
      assert_equal(BigDecimal('0'), credit_note.sub_total)
      assert_equal(BigDecimal('0'), credit_note.total_tax)
      assert_equal(BigDecimal('0'), credit_note.total)
    }
  end

  def test_type_helper_methods
    # Test accounts receivable credit_notes.
    credit_note = create_test_credit_note({:type => 'ACCRECCREDIT'})
    assert_equal(true,  credit_note.accounts_receivable?, "Accounts RECEIVABLE credit_note doesn't think it is.")
    assert_equal(false, credit_note.accounts_payable?,    "Accounts RECEIVABLE credit_note thinks it's payable.")

    # Test accounts payable credit_notes.
    credit_note = create_test_credit_note({:type => 'ACCPAYCREDIT'})
    assert_equal(false, credit_note.accounts_receivable?, "Accounts PAYABLE credit_note doesn't think it is.")
    assert_equal(true,  credit_note.accounts_payable?,    "Accounts PAYABLE credit_note thinks it's receivable.")
  end


  # Make sure that the create_test_credit_note method is working correctly
  # with all the defaults and overrides.
  def test_create_test_credit_note_defaults_working
    credit_note = create_test_credit_note

    # Test credit_note defaults.
    assert_equal('ACCRECCREDIT', credit_note.type)
    assert_kind_of(Date, credit_note.date)
    assert_equal('12345', credit_note.credit_note_number)
    assert_equal('MY REFERENCE FOR THIS CREDIT NOTE', credit_note.reference)
    assert_equal("Exclusive", credit_note.line_amount_types)

    # Test the contact defaults.
    assert_equal('00000000-0000-0000-0000-000000000000', credit_note.contact.contact_id)
    assert_equal('CONTACT NAME', credit_note.contact.name)

    # Test address defaults.
    assert_equal('DEFAULT', credit_note.contact.address.address_type)
    assert_equal('LINE 1 OF THE ADDRESS', credit_note.contact.address.line_1)

    # Test phone defaults.
    assert_equal('DEFAULT', credit_note.contact.phone.phone_type)
    assert_equal('12345678', credit_note.contact.phone.number)

    # Test the line_item defaults.
    assert_equal('A LINE ITEM', credit_note.line_items.first.description)
    assert_equal('200', credit_note.line_items.first.account_code)
    assert_equal(BigDecimal('100'), credit_note.line_items.first.unit_amount)
    assert_equal(BigDecimal('12.5'), credit_note.line_items.first.tax_amount)

    # Test overriding an credit_note parameter (assume works for all).
    credit_note = create_test_credit_note({:type => 'ACCPAYCREDIT'})
    assert_equal('ACCPAYCREDIT', credit_note.type)

    # Test overriding a contact/address/phone parameter (assume works for all).
    credit_note = create_test_credit_note({}, {:name => 'OVERRIDDEN NAME', :address => {:line_1 => 'OVERRIDDEN LINE 1'}, :phone => {:number => '999'}})
    assert_equal('OVERRIDDEN NAME', credit_note.contact.name)
    assert_equal('OVERRIDDEN LINE 1', credit_note.contact.address.line_1)
    assert_equal('999', credit_note.contact.phone.number)

    # Test overriding line_items with hash.
    credit_note = create_test_credit_note({}, {}, {:description => 'OVERRIDDEN LINE ITEM'})
    assert_equal(1, credit_note.line_items.size)
    assert_equal('OVERRIDDEN LINE ITEM', credit_note.line_items.first.description)
    assert_equal(BigDecimal('100'), credit_note.line_items.first.unit_amount)

    # Test overriding line_items with array of 2 line_items.
    credit_note = create_test_credit_note({}, {}, [
      {:description => 'OVERRIDDEN ITEM 1'},
      {:description => 'OVERRIDDEN ITEM 2', :account_code => '200', :unit_amount => BigDecimal('200'), :tax_amount => '25.0'}
    ])
    assert_equal(2, credit_note.line_items.size)
    assert_equal('OVERRIDDEN ITEM 1', credit_note.line_items[0].description)
    assert_equal(BigDecimal('100'), credit_note.line_items[0].unit_amount)
    assert_equal('OVERRIDDEN ITEM 2', credit_note.line_items[1].description)
    assert_equal(BigDecimal('200'), credit_note.line_items[1].unit_amount)
  end

  def test_auto_creation_of_associated_contact
    credit_note = create_test_credit_note({}, nil) # no contact
    assert(!credit_note.instance_variable_defined?("@contact"))

    new_contact = credit_note.contact
    assert_kind_of(XeroGateway::Contact, new_contact)
  end

  def test_add_line_item
    credit_note = create_test_credit_note({}, {}, nil) # no line_items
    assert_equal(0, credit_note.line_items.size)

    line_item_params = {:description => "Test Item 1", :unit_amount => 100}

    # Test adding line item by hash
    line_item = credit_note.add_line_item(line_item_params)
    assert_kind_of(XeroGateway::LineItem, line_item)
    assert_equal(line_item_params[:description], line_item.description)
    assert_equal(line_item_params[:unit_amount], line_item.unit_amount)
    assert_equal(1, credit_note.line_items.size)

    # Test adding line item by XeroGateway::LineItem
    line_item = credit_note.add_line_item(line_item_params)
    assert_kind_of(XeroGateway::LineItem, line_item)
    assert_equal(line_item_params[:description], line_item.description)
    assert_equal(line_item_params[:unit_amount], line_item.unit_amount)
    assert_equal(2, credit_note.line_items.size)

    # Test that pushing anything else into add_line_item fails.
    ["invalid", 100, nil, []].each do | invalid_object |
      assert_raise(XeroGateway::InvalidLineItemError) { credit_note.add_line_item(invalid_object) }
      assert_equal(2, credit_note.line_items.size)
    end
  end

  private

  def create_test_credit_note(credit_note_params = {}, contact_params = {}, line_item_params = [])
    unless credit_note_params.nil?
      credit_note_params = {
        :type => 'ACCRECCREDIT',
        :date => Date.today,
        :credit_note_number => '12345',
        :reference => "MY REFERENCE FOR THIS CREDIT NOTE",
        :line_amount_types => "Exclusive"
      }.merge(credit_note_params)
    end
    credit_note = XeroGateway::CreditNote.new(credit_note_params || {})

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

      # Create credit_note.contact from contact_params.
      credit_note.contact = XeroGateway::Contact.new(contact_params)
      credit_note.contact.address = XeroGateway::Address.new(stripped_address)
      credit_note.contact.phone = XeroGateway::Phone.new(stripped_phone)
    end

    unless line_item_params.nil?
      line_item_params = [line_item_params].flatten # always use an array, even if only a single hash passed in

      # At least one line item, make first have some defaults.
      line_item_params << {} if line_item_params.size == 0
      line_item_params[0] = {
        :description => "A LINE ITEM",
        :account_code => "200",
        :unit_amount => BigDecimal("100"),
        :tax_amount => BigDecimal("12.5"),
        :tracking => XeroGateway::TrackingCategory.new(:name => "blah", :options => "hello")
      }.merge(line_item_params[0])

      # Create credit_note.line_items from line_item_params
      line_item_params.each do | line_item |
        credit_note.add_line_item(line_item)
      end
    end

    credit_note
  end
end
