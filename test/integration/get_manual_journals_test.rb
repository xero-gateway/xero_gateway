require File.dirname(__FILE__) + '/../test_helper'

class GetManualJournalsTest < Test::Unit::TestCase
  include TestHelper

  INVALID_MANUAL_JOURNAL_ID = "99999999-9999-9999-9999-999999999999" unless defined?(INVALID_MANUAL_JOURNAL_ID)

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /ManualJournals(\/[0-9a-z\-]+)?$/i }.returns(get_file_as_string("manual_journals.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /ManualJournals$/ }.returns(get_file_as_string("create_manual_journal.xml"))

      # Get a manual journal with an invalid ID.
      @gateway.stubs(:http_get).with {|client, url, params| url =~ Regexp.new("ManualJournals/#{INVALID_MANUAL_JOURNAL_ID}") }.returns(get_file_as_string("manual_journal_not_found_error.xml"))
    end
  end

  def test_get_manual_journals
    # Make sure there is a manual journal in Xero to retrieve
    manual_journal = @gateway.create_manual_journal(create_test_manual_journal).manual_journal

    result = @gateway.get_manual_journals
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.manual_journals.collect {|i| i.narration}.include?(manual_journal.narration)
    assert result.manual_journals.collect {|i| i.manual_journal_id}.include?(manual_journal.manual_journal_id)
  end

  def test_get_manual_journals_with_modified_since_date
    # Create a test manual journal
    @gateway.create_manual_journal(create_test_manual_journal)

    # Check that it is returned
    result = @gateway.get_manual_journals(:modified_since => Date.today - 1)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.request_params.keys.include?(:ModifiedAfter) # make sure the flag was sent
  end

  def test_journal_lines_downloaded_set_correctly
    # No line items.
    response = @gateway.get_manual_journals
    assert_equal(true, response.success?)

    manual_journal = response.manual_journals.first
    assert_kind_of(XeroGateway::ManualJournal, manual_journal)
    assert !manual_journal.journal_lines_downloaded?
  end

  # Make sure that a reference to gateway is passed when the get_manual_journals response is parsed.
  def test_get_manual_journals_gateway_reference
    result = @gateway.get_manual_journals
    assert(result.success?)
    assert_not_equal(0, result.manual_journals.size)

    result.manual_journals.each do |manual_journal|
      assert(manual_journal.gateway === @gateway)
    end
  end

  # Test to make sure that we correctly error when a manual journal doesn't have an ID.
  # This should usually never be ecountered.
  def test_to_ensure_that_a_manual_journal_with_invalid_id_errors
    # Make sure there is a manual journal to retrieve, even though we will mangle it later.
    manual_journal = @gateway.create_manual_journal(create_test_manual_journal).manual_journal

    result = @gateway.get_manual_journals
    assert_equal(true, result.success?)

    manual_journal = result.manual_journals.first
    assert !manual_journal.journal_lines_downloaded?

    # Mangle invoice_id to invalid one.
    manual_journal.manual_journal_id = INVALID_MANUAL_JOURNAL_ID

    # Make sure we fail here.
    journal_lines = nil
    assert_raise(XeroGateway::ManualJournalNotFoundError) { journal_lines = manual_journal.journal_lines }
    assert_nil(journal_lines)
  end

end
