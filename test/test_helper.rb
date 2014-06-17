require "rubygems"

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require 'libxml'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb' unless defined?(XeroGateway)

module TestHelper
  # The integration tests can be run against the Xero test environment.  You mush have a company set up in the test
  # environment, and you must have set up a customer key for that account.
  #
  # You can then run the tests against the test environment using the commands (linux or mac):
  # export STUB_XERO_CALLS=false
  # rake test
  # (this probably won't work under OAuth?)
  #

  STUB_XERO_CALLS = ENV["STUB_XERO_CALLS"].nil? ? true : (ENV["STUB_XERO_CALLS"] == "true") unless defined? STUB_XERO_CALLS

  CONSUMER_KEY    = ENV["CONSUMER_KEY"]    || "fake_key"    unless defined?(CONSUMER_KEY)
  CONSUMER_SECRET = ENV["CONSUMER_SECRET"] || "fake_secret" unless defined?(CONSUMER_SECRET)

  # Helper constant for checking regex
  GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)


  def dummy_invoice(with_line_items = true)
     invoice = XeroGateway::Invoice.new({
       :invoice_type => "ACCREC",
       :date => Time.now,
       :due_date => Date.today + 20,
       :invoice_number => STUB_XERO_CALLS ? "INV-0001" : "#{Time.now.to_f}",
       :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
       :line_items_downloaded => with_line_items
     })
     invoice.contact = dummy_contact
     if with_line_items
       invoice.line_items << XeroGateway::LineItem.new(
         :description => "THE DESCRIPTION OF THE LINE ITEM",
         :unit_amount => 1000,
         :tax_amount => 125,
         :tracking => [
            XeroGateway::TrackingCategory.new(:name => "THE FIRST  TRACKING CATEGORY FOR THE LINE ITEM", :options => ["a", "b"]),
            XeroGateway::TrackingCategory.new(:name => "THE SECOND TRACKING CATEGORY FOR THE LINE ITEM", :options => "c")
         ]
       )
     end
     invoice
  end

  def dummy_credit_note(with_line_items = true)
     credit_note = XeroGateway::CreditNote.new({
       :type => "ACCRECCREDIT",
       :date => Time.now,
       :credit_note_number => STUB_XERO_CALLS ? "CN-0153" : "#{Time.now.to_f}",
       :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
       :line_items_downloaded => with_line_items
     })
     credit_note.contact = dummy_contact
     if with_line_items
       credit_note.line_items << XeroGateway::LineItem.new(
         :description => "THE DESCRIPTION OF THE LINE ITEM",
         :unit_amount => 1000,
         :tax_amount => 125,
         :tracking => [
            XeroGateway::TrackingCategory.new(:name => "THE FIRST  TRACKING CATEGORY FOR THE LINE ITEM", :options => ["a", "b"]),
            XeroGateway::TrackingCategory.new(:name => "THE SECOND TRACKING CATEGORY FOR THE LINE ITEM", :options => "c")
         ]
       )
     end
     credit_note
  end

  def dummy_contact
    unique_id = Time.now.to_f
    contact = XeroGateway::Contact.new(:name => STUB_XERO_CALLS ? "CONTACT NAME" : "THE NAME OF THE CONTACT #{unique_id}")
    contact.email = "bob#{unique_id}@example.com"
    contact.phone.number = "12345"
    contact.address.line_1 = "LINE 1 OF THE ADDRESS"
    contact.address.line_2 = "LINE 2 OF THE ADDRESS"
    contact.address.line_3 = "LINE 3 OF THE ADDRESS"
    contact.address.line_4 = "LINE 4 OF THE ADDRESS"
    contact.address.city = "WELLINGTON"
    contact.address.region = "WELLINGTON"
    contact.address.country = "NEW ZEALAND"
    contact.address.post_code = "6021"

    contact
  end

  def get_file_as_string(filename)
    data = ''
    f = File.open(File.dirname(__FILE__) + "/stub_responses/" + filename, "r")
    f.each_line do |line|
      data += line
    end
    f.close
    data
  end

  def get_file(filename)
    data = File.read( File.dirname(__FILE__) + "/stub_responses/" + filename)
  end

  def create_test_bank_transaction(params={}, contact_params={}, line_item_params={})
    params = {
      :type       => 'RECEIVE',
      :date       => Date.today,
      :reference  => '12345',
      :status     => 'ACTIVE',
    }.merge(params)
    bank_transaction = XeroGateway::BankTransaction.new(params)

    bank_transaction.contact = create_test_contact(contact_params)
    add_test_line_items(bank_transaction, line_item_params)
    bank_transaction.bank_account = create_test_account

    bank_transaction
  end

  def create_test_payment(params={}, contact_params={})
    params = {
      :payment_id       => 'a99a9aaa-9999-99a9-9aa9-aaaaaa9a9999',
      :payment_type     => 'ACCRECPAYMENT',
      :updated_at       => Time.now,
      :reference        => '12345',
      :account_id       => 'o99o9ooo-9999-99o9-9oo9-oooooo9o9999',
      :amount           => 1000.0,
      :currency_rate    => 1.0,
      :date             => Date.today.to_time,
      :invoice_id       => 'i99i9iii-9999-99i9-9ii9-iiiiii9i9999',
      :invoice_number   => 'INV-0001',
    }.merge(params)
    XeroGateway::Payment.new(params)
  end

  def create_test_report_bank_statement(params={}, body_params={})
    params = {
      :report_id        => 'BankStatement',
      :report_name      => 'BankStatement',
      :report_type      => 'BankStatement',
      :report_titles    => [],
      :report_date      => Date.today,
      :updated_at       => Time.now-3.days,
      :column_names     => [],
      :body             => []
    }.merge(params)
    XeroGateway::Report.new(params)
  end

  def add_test_line_items(bank_transaction, line_item_params={})
    if line_item_params
      line_item_params = [line_item_params].flatten # always use an array, even if only a single hash passed in

      # At least one line item, make first have some defaults.
      line_item_params << {} if line_item_params.size == 0
      line_item_params[0] = {
        :description  => "A LINE ITEM",
        :account_code => "200",
        :unit_amount  => BigDecimal.new("100"),
        :tax_amount   => BigDecimal.new("12.5"),
        :tracking     => XeroGateway::TrackingCategory.new(:name => "blah", :options => "hello")
      }.merge(line_item_params[0])

      # Create line_items from line_item_params
      line_item_params.each do |line_item|
        bank_transaction.add_line_item(line_item)
      end
    end
    bank_transaction
  end

  def create_test_account
    account = XeroGateway::Account.new(:account_id => "57cedda9")
    account.code = "200"
    account.name = "Sales"
    account.type = "REVENUE"
    account.tax_type = "OUTPUT"
    account.description = "Income from any normal business activity"
    account.enable_payments_to_account = false
    account
  end

  def create_test_contact(contact_params={})
    # Strip out :address key from contact_params to use as the default address.
    stripped_address = {
      :address_type => 'STREET',
      :line_1       => 'LINE 1 OF THE ADDRESS'
    }.merge(contact_params.delete(:address) || {})

    # Strip out :phone key from contact_params to use at the default phone.
    stripped_phone = {
      :phone_type => 'DEFAULT',
      :number     => '12345678'
    }.merge(contact_params.delete(:phone) || {})

    contact_params = {
      :contact_id => '00000000-0000-0000-0000-000000000000', # Just any valid GUID
      :name       => "CONTACT NAME",
      :first_name => "Bob",
      :last_name  => "Builder"
    }.merge(contact_params)

    contact = XeroGateway::Contact.new(contact_params)
    contact.address = XeroGateway::Address.new(stripped_address)
    contact.phone = XeroGateway::Phone.new(stripped_phone)
    contact
  end

  def create_test_manual_journal(params={}, journal_line_params={})
    params = {
      :date       => Date.today,
      :narration  => 'test narration',
      :status     => 'POSTED'
    }.merge(params)
    manual_journal = XeroGateway::ManualJournal.new(params)
    add_test_journal_lines(manual_journal, journal_line_params)
  end

  def add_test_journal_lines(manual_journal, journal_line_params)
    if journal_line_params
      journal_line_params = [journal_line_params].flatten # always use an array, even if only a single hash passed in

      # At least one line item, make first have some defaults.
      journal_line_params << {} if journal_line_params.size == 0
      journal_line_params[0] = {
        :description  => "FIRST LINE",
        :account_code => "200",
        :line_amount  => BigDecimal.new("100"),
        :tracking     => XeroGateway::TrackingCategory.new(:name => "blah", :options => "hello")
      }.merge(journal_line_params[0])
      params_line_1 = journal_line_params[1] || {}
      journal_line_params[1] = {
        :description  => "SECOND LINE",
        :account_code => "200",
        :line_amount  => BigDecimal.new("-100"),
        :tracking     => XeroGateway::TrackingCategory.new(:name => "blah2", :options => "hello2")
      }.merge(params_line_1)

      # Create line_items from line_item_params
      journal_line_params.each do |journal_line|
        manual_journal.add_journal_line(journal_line)
      end
    end
    manual_journal
  end

end
