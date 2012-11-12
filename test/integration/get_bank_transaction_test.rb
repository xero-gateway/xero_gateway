require File.dirname(__FILE__) + '/../test_helper'

class GetBankTransactionTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /BankTransactions(\/[0-9a-z\-]+)?$/i }.returns(get_file_as_string("bank_transaction.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /BankTransactions$/ }.returns(get_file_as_string("create_bank_transaction.xml"))
    end
  end

  def test_get_bank_transaction
    # Make sure there is a bank transaction in Xero to retrieve
    response = @gateway.create_bank_transaction(create_test_bank_transaction)
    bank_transaction = response.bank_transaction

    result = @gateway.get_bank_transaction(bank_transaction.bank_transaction_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.bank_transaction.bank_transaction_id, bank_transaction.bank_transaction_id
    assert_equal result.bank_transaction.reference, bank_transaction.reference
    assert result.bank_transaction.is_reconciled

    result = @gateway.get_bank_transaction(bank_transaction.bank_transaction_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert_equal result.bank_transaction.bank_transaction_id, bank_transaction.bank_transaction_id
  end

  def test_line_items_downloaded_set_correctly
    # Make sure there is a bank transaction in Xero to retrieve.
    example_bank_transaction = @gateway.create_bank_transaction(create_test_bank_transaction).bank_transaction
  
    # No line items.
    response = @gateway.get_bank_transaction(example_bank_transaction.bank_transaction_id)
    assert_equal(true, response.success?)
  
    bank_transaction = response.bank_transaction
    assert_kind_of(XeroGateway::LineItem, bank_transaction.line_items.first)
    assert_kind_of(XeroGateway::BankTransaction, bank_transaction)
    assert_equal(true, bank_transaction.line_items_downloaded?)
  end

end
