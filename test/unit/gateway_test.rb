require File.join(File.dirname(__FILE__), '../test_helper.rb')

class GatewayTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
  end

  context "GET methods" do
    should :get_invoices do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invoices.xml"), :code => "200"))
      result = @gateway.get_invoices
      assert result.response_item.first.is_a? XeroGateway::Invoice
    end

    should :get_invoice do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invoice.xml"), :code => "200"))
      result = @gateway.get_invoice('a99a9aaa-9999-99a9-9aa9-aaaaaa9a9999')
      assert result.response_item.is_a? XeroGateway::Invoice
    end

    should :get_credit_notes do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("credit_notes.xml"), :code => "200"))
      result = @gateway.get_credit_notes
      assert result.response_item.first.is_a? XeroGateway::CreditNote
    end

    should :get_credit_note do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("credit_notes.xml"), :code => "200"))
      result = @gateway.get_credit_note('a2b4370d-efd2-440d-894e-082f21d0b10a')
      assert result.response_item.first.is_a? XeroGateway::CreditNote
    end

    should :get_bank_transactions do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("bank_transaction.xml"), :code => "200"))
      result = @gateway.get_bank_transactions
      assert result.response_item.is_a? XeroGateway::BankTransaction
    end

    should :get_bank_transaction do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("bank_transactions.xml"), :code => "200"))
      result = @gateway.get_bank_transaction('c09661a2-a954-4e34-98df-f8b6d1dc9b19')
      assert result.response_item.is_a? XeroGateway::BankTransaction
    end

    should :get_manual_journals do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("manual_journals.xml"), :code => "200"))
      result = @gateway.get_manual_journals
      assert result.response_item.is_a? XeroGateway::ManualJournal
    end

    should :get_payments do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("payments.xml"), :code => "200"))
      result = @gateway.get_payments
      assert result.response_item.first.is_a? XeroGateway::Payment
    end

    should :get_contacts do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("contacts.xml"), :code => "200"))
      result = @gateway.get_contacts
      assert result.response_item.first.is_a? XeroGateway::Contact
    end

    should :get_contact_by_id do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("contact.xml"), :code => "200"))
      result = @gateway.get_contact_by_id('a99a9aaa-9999-99a9-9aa9-aaaaaa9a9999')
      assert result.response_item.is_a? XeroGateway::Contact
    end

    should :get_contact_by_number do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("contact.xml"), :code => "200"))
      result = @gateway.get_contact_by_number('12345')
      assert result.response_item.is_a? XeroGateway::Contact
    end

    context :get_report do
      should "get a BankStatements report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/bank_statement.xml"), :code => "200"))
        result = @gateway.get_report("BankStatement", bank_account_id: "c09661a2-a954-4e34-98df-f8b6d1dc9b19")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a AgedPayablesByContact report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/aged_payables_by_contact.xml"), :code => "200"))
        result = @gateway.get_report("AgedPayablesByContact", contactID: "c09661a2-a954-4e34-98df-f8b6d1dc9b19")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a AgedReceivablesByContact report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/aged_receivables_by_contact.xml"), :code => "200"))
        result = @gateway.get_report("AgedReceivablesByContact", contactID: "c09661a2-a954-4e34-98df-f8b6d1dc9b19")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a BalanceSheet report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/balance_sheet.xml"), :code => "200"))
        result = @gateway.get_report("BalanceSheet")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a BankSummary report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/bank_summary.xml"), :code => "200"))
        result = @gateway.get_report("BankSummary")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a ExecutiveSummary report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/executive_summary.xml"), :code => "200"))
        result = @gateway.get_report("ExecutiveSummary")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a ProfitAndLoss report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/profit_and_loss.xml"), :code => "200"))
        result = @gateway.get_report("ProfitAndLoss")
        assert result.response_item.is_a? XeroGateway::Report
      end

      should "get a TrialBalance report" do
        XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("reports/trial_balance.xml"), :code => "200"))
        result = @gateway.get_report("TrialBalance")
        assert result.response_item.is_a? XeroGateway::Report
      end
    end
  end

  context "with error handling" do
    should "handle token expired" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("token_expired"), :code => "401"))

      assert_raises XeroGateway::OAuth::TokenExpired do
        @gateway.get_accounts
      end
    end

    should "handle invalid request tokens" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invalid_request_token"), :code => "401"))

      assert_raises XeroGateway::OAuth::TokenInvalid do
        @gateway.get_accounts
      end
    end

    should "handle invalid consumer key" do
     XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invalid_consumer_key"), :code => "401"))

      assert_raises XeroGateway::OAuth::TokenInvalid do
        @gateway.get_accounts
      end
    end

    should "handle rate limit exceeded" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("rate_limit_exceeded"), :code => "401"))

      assert_raises XeroGateway::OAuth::RateLimitExceeded do
        @gateway.get_accounts
      end
    end

    should "handle unknown errors" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("bogus_oauth_error"), :code => "401"))

      assert_raises XeroGateway::OAuth::UnknownError do
        @gateway.get_accounts
      end
    end

    should "handle ApiExceptions" do
      XeroGateway::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "400"))

      assert_raises XeroGateway::ApiException do
        @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end

    should "handle invoices not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::InvoiceNotFoundError do
        @gateway.get_invoice('unknown-invoice-id')
      end
    end

    should "handle bank transactions not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::BankTransactionNotFoundError do
        @gateway.get_bank_transaction('unknown-bank-transaction-id')
      end
    end

    should "handle credit notes not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::CreditNoteNotFoundError do
        @gateway.get_credit_note('unknown-credit-note-id')
      end
    end

    should "handle manual journals not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::ManualJournalNotFoundError do
        @gateway.get_manual_journal('unknown-manual-journal-id')
      end
    end

    should "handle payments not found" do
      XeroGateway::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("api_exception.xml"), :code => "404"))

      assert_raises XeroGateway::PaymentNotFoundError do
        @gateway.get_payments
      end
    end

    should "handle random root elements" do
      XeroGateway::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => "<RandomRootElement></RandomRootElement>", :code => "200"))

      assert_raises XeroGateway::UnparseableResponse do
        @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end

    should "handle no root element" do
      XeroGateway::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_file_as_string("no_certificates_registered"), :code => 400))

      assert_raises RuntimeError do
        response = @gateway.create_invoice(XeroGateway::Invoice.new)
      end
    end
  end

  def test_unknown_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/AN_INVALID_ID$/ }.returns(get_file_as_string("unknown_error.xml"))
    end

    result = @gateway.get_invoice("AN_INVALID_ID")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert !result.errors.first.type.nil?
    assert !result.errors.first.description.nil?
  end

  def test_object_not_found_error_handling
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/UNKNOWN_INVOICE_NO$/ }.returns(get_file_as_string("invoice_not_found_error.xml"))
    end

    result = @gateway.get_invoice("UNKNOWN_INVOICE_NO")
    assert !result.success?
    assert_equal 1, result.errors.size
    assert_equal "Xero.API.Library.Exceptions.ObjectDoesNotExistException", result.errors.first.type
    assert !result.errors.first.description.nil?
  end
end
