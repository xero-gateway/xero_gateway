require File.dirname(__FILE__) + '/../test_helper'

class CreateCreditNoteTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /CreditNotes$/ }.returns(get_file_as_string("create_credit_note.xml"))          
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /CreditNotes$/ }.returns(get_file_as_string("credit_note.xml"))          
    end
  end
  
  def test_create_credit_note
    example_credit_note = dummy_credit_note.dup
    
    result = @gateway.create_credit_note(example_credit_note)
    assert_valid_credit_note_save_response(result, example_credit_note)
  end
  
  def test_create_from_credit_note
    example_credit_note = dummy_credit_note.dup
    
    credit_note = @gateway.build_credit_note(example_credit_note)
    result = credit_note.create
    assert_valid_credit_note_save_response(result, example_credit_note)
  end
  
  def test_create_credit_note_valid
    example_credit_note = dummy_credit_note.dup
    assert_equal true, example_credit_note.valid?, "credit_note is invalid - errors:\n\t#{example_credit_note.errors.map { | error | "#{error[0]} #{error[1]}"}.join("\n\t")}"
  end
  
  private
  
    def assert_valid_credit_note_save_response(result, example_credit_note)
      assert_kind_of XeroGateway::Response, result
      assert result.success?
      assert !result.request_xml.nil?
      assert !result.response_xml.nil?
      assert !result.credit_note.credit_note_id.nil?
      assert result.credit_note.credit_note_number == example_credit_note.credit_note_number
      assert result.credit_note.credit_note_id =~ GUID_REGEX
    end
    
end
