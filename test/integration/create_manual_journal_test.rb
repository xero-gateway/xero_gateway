require File.dirname(__FILE__) + '/../test_helper'

class CreateManualJournalTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /ManualJournals$/ }.returns(get_file_as_string("create_manual_journal.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /ManualJournals$/ }.returns(get_file_as_string("manual_journal.xml"))
    end
  end

  def test_create_manual_journal
    example_manual_journal = create_test_manual_journal.dup

    result = @gateway.create_manual_journal(example_manual_journal)
    assert_kind_of XeroGateway::Response, result
    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?
    assert !result.manual_journal.manual_journal_id.nil?
    assert example_manual_journal.manual_journal_id =~ GUID_REGEX
  end

  def test_create_manual_journal_valid
    example_manual_journal = create_test_manual_journal.dup
    assert_equal true, example_manual_journal.valid?,
      "manual_journal is invalid - errors:\n\t#{example_manual_journal.errors.map { | error | "#{error[0]} #{error[1]}"}.join("\n\t")}"
  end

end
