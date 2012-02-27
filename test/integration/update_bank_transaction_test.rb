require File.dirname(__FILE__) + '/../test_helper'

class UpdateBankTransactionTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /BankTransactions$/ }.returns(get_file_as_string("create_bank_transaction.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /BankTransactions$/ }.returns(get_file_as_string("bank_transaction.xml"))
    end
  end

  def test_update_bank_transaction
    bank_transaction = @gateway.create_bank_transaction(create_test_bank_transaction).bank_transaction

    today = Date.today
    bank_transaction.date = today

    result = @gateway.update_bank_transaction(bank_transaction)

    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?
    assert_equal bank_transaction.bank_transaction_id, result.bank_transaction.bank_transaction_id
    assert_equal today, result.bank_transaction.date if !STUB_XERO_CALLS
  end
end
