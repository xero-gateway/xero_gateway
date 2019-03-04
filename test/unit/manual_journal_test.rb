require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ManualJournalTest < Test::Unit::TestCase
  include TestHelper

  context "creating test manual journals" do
    should "work" do
      manual_journal = create_test_manual_journal

      # test transaction defaults
      assert_equal 'POSTED', manual_journal.status
      assert_kind_of Date, manual_journal.date
      assert_equal 'test narration', manual_journal.narration

      # Test the journal_line defaults.
      journal_line = manual_journal.journal_lines.first
      assert_equal('FIRST LINE', journal_line.description)
      assert_equal('200', journal_line.account_code)
      assert_equal(BigDecimal('100'), journal_line.line_amount)
    end

    should "allow overriding transaction defaults" do
      assert_equal 'DRAFT', create_test_manual_journal(:status => 'DRAFT').status
    end
  end

  context "adding journal lines" do
    setup do
      @manual_journal = create_test_manual_journal
    end

    should "work" do
      assert_equal 2, @manual_journal.journal_lines.size
      assert @manual_journal.valid?

      journal_line_params = {:description => "Test Item 1", :line_amount => 100, :account_code => '200'}

      # Test adding line item by hash
      journal_line = @manual_journal.add_journal_line(journal_line_params)
      assert_kind_of(XeroGateway::JournalLine, journal_line)
      assert_equal(journal_line_params[:description], journal_line.description)
      assert_equal(journal_line_params[:line_amount], journal_line.line_amount)
      assert_equal(3, @manual_journal.journal_lines.size)

      # Test adding line item by XeroGateway::JournalLine
      journal_line = @manual_journal.add_journal_line(journal_line_params)
      assert_kind_of(XeroGateway::JournalLine, journal_line)
      assert_equal(journal_line_params[:description], journal_line.description)
      assert_equal(journal_line_params[:line_amount], journal_line.line_amount)
      assert_equal(4, @manual_journal.journal_lines.size)

      # Test that having only 1 journal line fails.
      @manual_journal.journal_lines = []
      @manual_journal.add_journal_line(journal_line_params)
      assert !@manual_journal.valid?
    end
  end


  context "building and parsing XML" do
    should "work vice versa" do
      manual_journal = create_test_manual_journal
      manual_journal_as_xml = manual_journal.to_xml
      manual_journal_element = REXML::XPath.first(REXML::Document.new(manual_journal_as_xml), "/ManualJournal")

      # checking for mandatory fields
      assert_xml_field manual_journal_element, 'Date'
      assert_xml_field manual_journal_element, 'Narration', :value => 'test narration'
      assert_xml_field manual_journal_element, 'Status', :value => 'POSTED'

      parsed_manual_journal = XeroGateway::ManualJournal.from_xml(manual_journal_element)
      assert_equal(manual_journal, parsed_manual_journal)
    end

    should "work for optional params" do
      manual_journal = create_test_manual_journal(:url => 'http://example.com?with=params&and=more')
      manual_journal_element = REXML::XPath.first(REXML::Document.new(manual_journal.to_xml), "/ManualJournal")

      assert_xml_field manual_journal_element, 'Url', :value => 'http://example.com\?with=params&amp;and=more'

      parsed_manual_journal = XeroGateway::ManualJournal.from_xml(manual_journal_element)
      assert_equal 'http://example.com?with=params&and=more', parsed_manual_journal.url
    end
  end

private

  def assert_xml_field(xml, field_name, options={})
    assert_match(/#{field_name}/, xml.to_s, "Didn't find the field #{field_name} in the XML document!")
    assert_match(/#{field_name}.*#{options[:value]}.*#{field_name}/, xml.to_s, "The field #{field_name} was expected to be '#{options[:value]}'!") if options[:value]
  end

end
