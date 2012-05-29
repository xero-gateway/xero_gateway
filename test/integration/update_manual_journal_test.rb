require File.dirname(__FILE__) + '/../test_helper'

class UpdateManualJournalTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /ManualJournals$/ }.returns(get_file_as_string("create_manual_journal.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /ManualJournals$/ }.returns(get_file_as_string("manual_journal.xml"))
    end
  end

  def test_update_manual_journal
    manual_journal = @gateway.create_manual_journal(create_test_manual_journal).manual_journal

    today = Date.today
    manual_journal.date = today

    result = @gateway.update_manual_journal(manual_journal)

    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?
    assert_equal manual_journal.manual_journal_id, result.manual_journal.manual_journal_id
    assert_equal today, result.manual_journal.date if !STUB_XERO_CALLS
  end
end
