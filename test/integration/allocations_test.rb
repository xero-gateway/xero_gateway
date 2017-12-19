require File.dirname(__FILE__) + '/../test_helper'

class CreateAllocationsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = 'DUMMY_URL'
      @gateway.stubs(:http_put).with { |_client, url, _body, _params| url =~ /CreditNotes\/.*\/Allocations$/ }.returns(get_file_as_string('allocations.xml'))
    end
  end

  def test_create_allocation
    example_allocation = dummy_allocation.dup
    example_credit_note = dummy_credit_note.dup
    result = @gateway.allocate_credit_note(example_credit_note.credit_note_id,
                                           example_allocation.invoice_id,
                                           example_allocation.applied_amount)

    assert_valid_allocation_save_response(result, example_allocation)
  end

  private

  def assert_valid_allocation_save_response(result, example_allocation)
    assert_kind_of XeroGateway::Response, result
    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?
    assert_kind_of(Array, result.allocations)
    assert result.allocations.first.invoice_id == example_allocation.invoice_id
  end
end
