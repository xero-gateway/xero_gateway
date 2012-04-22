require File.dirname(__FILE__) + '/../test_helper'

class CreateBankTransactionTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /BankTransactions$/ }.returns(get_file_as_string("create_bank_transaction.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /BankTransactions$/ }.returns(get_file_as_string("bank_transaction.xml"))
    end
  end

  def test_create_bank_transaction
    example_bank_transaction = create_test_bank_transaction.dup

    result = @gateway.create_bank_transaction(example_bank_transaction)
    assert_kind_of XeroGateway::Response, result
    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?
    assert !result.bank_transaction.bank_transaction_id.nil?
    assert example_bank_transaction.bank_transaction_id =~ GUID_REGEX
  end

  def test_create_bank_transaction_valid
    example_bank_transaction = create_test_bank_transaction.dup
    assert_equal true, example_bank_transaction.valid?,
      "bank_transaction is invalid - errors:\n\t#{example_bank_transaction.errors.map { | error | "#{error[0]} #{error[1]}"}.join("\n\t")}"
  end

  private


end
