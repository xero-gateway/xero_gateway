require File.join(File.dirname(__FILE__), '../test_helper.rb')

class BankTransactionTest < Test::Unit::TestCase
  include TestHelper

  context "creating test bank transactions" do
    should "work" do
      bank_transaction = create_test_bank_transaction

      # test transaction defaults
      assert_equal 'RECEIVE', bank_transaction.type
      assert_kind_of Date, bank_transaction.date
      assert_equal '12345', bank_transaction.reference
      assert_equal 'ACTIVE', bank_transaction.status

      # Test the contact defaults.
      contact = bank_transaction.contact
      assert_equal '00000000-0000-0000-0000-000000000000', contact.contact_id
      assert_equal 'CONTACT NAME', contact.name

      # Test address defaults.
      assert_equal 'STREET', contact.address.address_type
      assert_equal 'LINE 1 OF THE ADDRESS', contact.address.line_1

      # Test phone defaults.
      assert_equal('DEFAULT', contact.phone.phone_type)
      assert_equal('12345678', contact.phone.number)

      # Test the line_item defaults.
      line_item = bank_transaction.line_items.first
      assert_equal('A LINE ITEM', line_item.description)
      assert_equal('200', line_item.account_code)
      assert_equal(BigDecimal.new('100'), line_item.unit_amount)
      assert_equal(BigDecimal.new('12.5'), line_item.tax_amount)
    end

    should "allow overriding transaction defaults" do
      assert_equal 'SPEND', create_test_bank_transaction(:type => 'SPEND').type
    end
  end

  context "adding line items" do
    setup do
      @bank_transaction = create_test_bank_transaction({}, {}, nil) # no line_items
    end

    should "work" do
      assert_equal(0, @bank_transaction.line_items.size)

      line_item_params = {:description => "Test Item 1", :unit_amount => 100}

      # Test adding line item by hash
      line_item = @bank_transaction.add_line_item(line_item_params)
      assert_kind_of(XeroGateway::LineItem, line_item)
      assert_equal(line_item_params[:description], line_item.description)
      assert_equal(line_item_params[:unit_amount], line_item.unit_amount)
      assert_equal(1, @bank_transaction.line_items.size)

      # Test adding line item by XeroGateway::LineItem
      line_item = @bank_transaction.add_line_item(line_item_params)
      assert_kind_of(XeroGateway::LineItem, line_item)
      assert_equal(line_item_params[:description], line_item.description)
      assert_equal(line_item_params[:unit_amount], line_item.unit_amount)
      assert_equal(2, @bank_transaction.line_items.size)

      # Test that pushing anything else into add_line_item fails.
      ["invalid", 100, nil, []].each do | invalid_object |
        assert_raise(XeroGateway::InvalidLineItemError) { @bank_transaction.add_line_item(invalid_object) }
        assert_equal(2, @bank_transaction.line_items.size)
      end
    end
  end


  context "building and parsing XML" do
    should "work vice versa" do
      bank_transaction = create_test_bank_transaction
      bank_transaction_as_xml = bank_transaction.to_xml
      bank_transaction_element = REXML::XPath.first(REXML::Document.new(bank_transaction_as_xml), "/BankTransaction")

      # checking for mandatory fields
      assert_xml_field bank_transaction_element, 'Type', :value => 'RECEIVE'
      assert_xml_field bank_transaction_element, 'Date'
      assert_xml_field bank_transaction_element, 'Reference', :value => '12345'
      assert_xml_field bank_transaction_element, 'Status', :value => 'ACTIVE'
      assert_xml_field bank_transaction_element, 'Contact', :value => 'CONTACT NAME'
      assert_xml_field bank_transaction_element, 'LineItems', :value => 'A LINE ITEM'
      assert_xml_field bank_transaction_element, 'BankAccount'

      parsed_bank_transaction = XeroGateway::BankTransaction.from_xml(bank_transaction_element)
      assert_equal(bank_transaction, parsed_bank_transaction)
    end

    should "work for optional params" do
      bank_transaction = create_test_bank_transaction(:url => 'http://example.com?with=params&and=more')
      bank_transaction_element = REXML::XPath.first(REXML::Document.new(bank_transaction.to_xml), "/BankTransaction")

      assert_xml_field bank_transaction_element, 'Url', :value => 'http://example.com\?with=params&amp;and=more'

      # test total without downloading each line items
      total_elem = REXML::Element.new('Total')
      total_elem.text = '1000'
      bank_transaction_element.add_element(total_elem)

      XeroGateway::BankTransaction.any_instance.stubs(:line_items_downloaded?).returns(false)
      parsed_bank_transaction = XeroGateway::BankTransaction.from_xml(bank_transaction_element)
      assert_equal 'http://example.com?with=params&and=more', parsed_bank_transaction.url
      assert_equal BigDecimal.new('1000'), parsed_bank_transaction.total
    end

    should "ignore missing contact" do
      bank_transaction = create_test_bank_transaction
      bank_transaction.contact = nil
      bank_transaction.to_xml
    end

    should "ignore missing bank account" do
      bank_transaction = create_test_bank_transaction
      bank_transaction.bank_account = nil
      bank_transaction.to_xml
    end
  end

private

  def assert_xml_field(xml, field_name, options={})
    assert_match /#{field_name}/, xml.to_s, "Didn't find the field #{field_name} in the XML document!"
    if options[:value]
      assert_match /#{field_name}.*#{options[:value]}.*#{field_name}/, xml.to_s, "The field #{field_name} was expected to be '#{options[:value]}'!"
    end
  end

end
