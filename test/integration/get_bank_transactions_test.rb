require File.dirname(__FILE__) + '/../test_helper'

class GetBankTransactionsTest < Test::Unit::TestCase
  include TestHelper

  INVALID_BANK_TRANSACTION_ID = "99999999-9999-9999-9999-999999999999" unless defined?(INVALID_BANK_TRANSACTION_ID)

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /BankTransactions(\/[0-9a-z\-]+)?$/i }.returns(get_file_as_string("bank_transactions.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /BankTransactions$/ }.returns(get_file_as_string("create_bank_transaction.xml"))

      # Get a bank transaction with an invalid ID.
      @gateway.stubs(:http_get).with {|client, url, params| url =~ Regexp.new("BankTransactions/#{INVALID_BANK_TRANSACTION_ID}") }.returns(get_file_as_string("bank_transaction_not_found_error.xml"))
    end
  end

  def test_get_bank_transactions
    # Make sure there is a bank transaction in Xero to retrieve
    bank_transaction = @gateway.create_bank_transaction(create_test_bank_transaction).bank_transaction

    result = @gateway.get_bank_transactions
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.bank_transactions.collect {|i| i.reference}.include?(bank_transaction.reference)
    assert result.bank_transactions.collect {|i| i.bank_transaction_id}.include?(bank_transaction.bank_transaction_id)
    assert result.bank_transactions.collect {|i| i.updated_at}.include?(bank_transaction.updated_at)
    assert result.bank_transactions.last.updated_at.is_a?(Time)
  end

  def test_get_bank_transactions_with_modified_since_date
    # Create a test bank transaction
    @gateway.create_bank_transaction(create_test_bank_transaction)

    # Check that it is returned
    result = @gateway.get_bank_transactions(:modified_since => Date.today - 1)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.request_params.keys.include?(:ModifiedAfter) # make sure the flag was sent
  end

  def test_line_items_downloaded_set_correctly
    # No line items.
    response = @gateway.get_bank_transactions
    assert_equal(true, response.success?)

    bank_transaction = response.bank_transactions.first
    assert_kind_of(XeroGateway::BankTransaction, bank_transaction)
    assert_equal(false, bank_transaction.line_items_downloaded?)
  end

  # Make sure that a reference to gateway is passed when the get_bank_transactions response is parsed.
  def test_get_bank_transactions_gateway_reference
    result = @gateway.get_bank_transactions
    assert(result.success?)
    assert_not_equal(0, result.bank_transactions.size)

    result.bank_transactions.each do |bank_transaction|
      assert(bank_transaction.gateway === @gateway)
    end
  end

  # Test to make sure that we correctly error when a bank transaction doesn't have an ID.
  # This should usually never be ecountered.
  def test_to_ensure_that_a_bank_transaction_with_invalid_id_errors
    # Make sure there is a bank transaction to retrieve, even though we will mangle it later.
    bank_transaction = @gateway.create_bank_transaction(create_test_bank_transaction).bank_transaction

    result = @gateway.get_bank_transactions
    assert_equal(true, result.success?)

    bank_transaction = result.bank_transactions.first
    assert_equal(false, bank_transaction.line_items_downloaded?)

    # Mangle invoice_id to invalid one.
    bank_transaction.bank_transaction_id = INVALID_BANK_TRANSACTION_ID

    # Make sure we fail here.
    line_items = nil
    assert_raise(XeroGateway::BankTransactionNotFoundError) { line_items = bank_transaction.line_items }
    assert_nil(line_items)
  end

end
