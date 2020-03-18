require File.dirname(__FILE__) + '/../test_helper'

class GetCreditNotesTest < Test::Unit::TestCase
  include TestHelper
  
  INVALID_CREDIT_NOTE_ID = "99999999-9999-9999-9999-999999999999" unless defined?(INVALID_CREDIT_NOTE_ID)
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /CreditNotes/ }.returns(get_file_as_string("credit_notes.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /CreditNotes$/ }.returns(get_file_as_string("create_credit_note.xml"))

      # Get an credit_note with an invalid ID number.
      @gateway.stubs(:http_get).with {|client, url, params| url =~ Regexp.new("CreditNotes/#{INVALID_CREDIT_NOTE_ID}") }.returns(get_file_as_string("credit_note_not_found_error.xml"))
    end
  end
  
  def test_get_credit_notes
    # Make sure there is an credit_note in Xero to retrieve
    credit_note = @gateway.create_credit_note(dummy_credit_note).credit_note
    
    result = @gateway.get_credit_notes
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?  
    assert result.credit_notes.collect {|i| i.credit_note_number}.include?(credit_note.credit_note_number)
  end
  
  def test_get_credit_notes_with_modified_since_date
    # Create a test credit_note
    credit_note = dummy_credit_note
    @gateway.create_credit_note(credit_note)
    
    # Check that it is returned
    result = @gateway.get_credit_notes(:modified_since => Date.today - 1)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?    
    assert result.request_params.keys.include?(:ModifiedAfter) # make sure the flag was sent
    assert result.credit_notes.collect {|response_credit_note| response_credit_note.credit_note_number}.include?(credit_note.credit_note_number)
  end
  
  def test_line_items_downloaded_set_correctly
    # No line items.
    response = @gateway.get_credit_notes
    assert_equal(true, response.success?)
    
    credit_note = response.credit_notes.first
    assert_kind_of(XeroGateway::CreditNote, credit_note)
    assert_equal(false, credit_note.line_items_downloaded?)
  end
  
  # Make sure that a reference to gateway is passed when the get_credit_notes response is parsed.
  def test_get_contacts_gateway_reference
    result = @gateway.get_credit_notes
    assert(result.success?)
    assert_not_equal(0, result.credit_notes.size)
    
    result.credit_notes.each do | credit_note |
      assert(credit_note.gateway === @gateway)
    end
  end
  
  # Test to make sure that we correctly error when an credit_note doesn't have an ID.
  # This should usually never be ecountered, but might if a draft credit_note is deleted from Xero.
  def test_to_ensure_that_an_credit_note_with_invalid_id_errors
    # Make sure there is an credit_note to retrieve, even though we will mangle it later.
    credit_note = @gateway.create_credit_note(dummy_credit_note).credit_note
    
    result = @gateway.get_credit_notes
    assert_equal(true, result.success?)
    
    credit_note = result.credit_notes.first
    assert_equal(false, credit_note.line_items_downloaded?)
    
    # Mangle credit_note_id to invalid one.
    credit_note.credit_note_id = INVALID_CREDIT_NOTE_ID
    
    # Make sure we fail here.
    line_items = nil
    assert_raise(XeroGateway::CreditNoteNotFoundError) { line_items = credit_note.line_items }
    assert_nil(line_items)
    
  end
  
end
