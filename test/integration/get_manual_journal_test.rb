require File.dirname(__FILE__) + '/../test_helper'

class GetManualJournalTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /ManualJournals(\/[0-9a-z\-]+)?$/i }.returns(get_file_as_string("manual_journal.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /ManualJournals$/ }.returns(get_file_as_string("create_manual_journal.xml"))
    end
  end

  def test_get_manual_journal
    # Make sure there is a manual journal in Xero to retrieve
    response = @gateway.create_manual_journal(create_test_manual_journal)
    manual_journal = response.manual_journal

    result = @gateway.get_manual_journal(manual_journal.manual_journal_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.manual_journal.manual_journal_id, manual_journal.manual_journal_id
    assert_equal result.manual_journal.narration, manual_journal.narration

    result = @gateway.get_manual_journal(manual_journal.manual_journal_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.manual_journal.manual_journal_id, manual_journal.manual_journal_id
  end

  def test_journal_lines_downloaded_set_correctly
    # Make sure there is a manual journal in Xero to retrieve.
    example_manual_journal = @gateway.create_manual_journal(create_test_manual_journal).manual_journal
  
    # No line items.
    response = @gateway.get_manual_journal(example_manual_journal.manual_journal_id)
    assert response.success?
  
    manual_journal = response.manual_journal
    assert_kind_of(XeroGateway::JournalLine, manual_journal.journal_lines.first)
    assert_kind_of(XeroGateway::ManualJournal, manual_journal)
    assert manual_journal.journal_lines_downloaded?
  end

end
