require File.dirname(__FILE__) + '/../test_helper'

class GetCreditNoteTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /CreditNotes(\/[0-9a-z\-]+)?$/i }.returns(get_file_as_string("credit_note.xml"))              
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /CreditNotes$/ }.returns(get_file_as_string("create_credit_note.xml"))          
    end
  end
  
  def test_get_credit_note
    # Make sure there is an credit_note in Xero to retrieve
    credit_note = @gateway.create_credit_note(dummy_credit_note).credit_note

    result = @gateway.get_credit_note(credit_note.credit_note_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?    
    assert_equal result.credit_note.credit_note_number, credit_note.credit_note_number

    result = @gateway.get_credit_note(credit_note.credit_note_number)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?    
    assert_equal result.credit_note.credit_note_id, credit_note.credit_note_id
  end
  
  def test_line_items_downloaded_set_correctly
    # Make sure there is an credit_note in Xero to retrieve.
    example_credit_note = @gateway.create_credit_note(dummy_credit_note).credit_note
    
    # No line items.
    response = @gateway.get_credit_note(example_credit_note.credit_note_id)
    assert_equal(true, response.success?)
    
    credit_note = response.credit_note
    assert_kind_of(XeroGateway::LineItem, credit_note.line_items.first)
    assert_kind_of(XeroGateway::CreditNote, credit_note)
    assert_equal(true, credit_note.line_items_downloaded?)
  end
  
end
