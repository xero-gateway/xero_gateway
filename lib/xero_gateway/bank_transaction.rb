module XeroGateway
  class BankTransaction
    include Dates
    include LineItemCalculations

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    TYPES = {
      'RECEIVE' => 'Receive Bank Transaction',
      'SPEND'   => 'Spend Bank Transaction',
    } unless defined?(TYPES)

    STATUSES = {
      'ACTIVE'  => 'Bank Transaction is active',
      'DELETED' => 'Bank Transaction is deleted',
    } unless defined?(STATUSES)

    # Xero::Gateway associated with this invoice.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # Represents whether the line_items have been downloaded when getting from GET /API.XRO/2.0/BankTransactions
    attr_accessor :line_items_downloaded

    # accessible fields
    attr_accessor :bank_transaction_id, :type, :date, :reference, :status, :contact, :line_items, :bank_account, :url, :is_reconciled, :updated_at

    def initialize(params = {})
      @errors ||= []
      @payments ||= []

      # Check if the line items have been downloaded.
      @line_items_downloaded = (params.delete(:line_items_downloaded) == true)

      # params = {
      #   :line_amount_types => "Exclusive"
      # }.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @line_items ||= []
    end

    def ==(other)
      ['type', 'reference', 'status', 'contact', 'line_items', 'bank_account'].each do |field|
        return false if send(field) != other.send(field)
      end

      ["date"].each do |field|
        return false if send(field).to_s != other.send(field).to_s
      end
      return true
    end

    # Validate the BankTransaction record according to what will be valid by the gateway.
    #
    # Usage:
    #  bank_transaction.valid?     # Returns true/false
    #
    #  Additionally sets bank_transaction.errors array to an array of field/error.
    def valid?
      @errors = []

      if !bank_transaction_id.nil? && bank_transaction_id !~ GUID_REGEX
        @errors << ['bank_transaction_id', 'must be blank or a valid Xero GUID']
      end

      if type && !TYPES[type]
        @errors << ['type', "must be one of #{TYPES.keys.join('/')}"]
      end

      if status && !STATUSES[status]
        @errors << ['status', "must be one of #{STATUSES.keys.join('/')}"]
      end

      unless date
        @errors << ['date', "can't be blank"]
      end

      # Make sure contact is valid.
      unless @contact && @contact.valid?
        @errors << ['contact', 'is invalid']
      end

      # Make sure all line_items are valid.
      unless line_items.all? { | line_item | line_item.valid? }
        @errors << ['line_items', "at least one line item invalid"]
      end

      @errors.size == 0
    end


    def line_items_downloaded?
      @line_items_downloaded
    end

    %w(sub_total tax_total total).each do |line_item_total_type|
      define_method("#{line_item_total_type}=") do |new_total|
        instance_variable_set("@#{line_item_total_type}", new_total) unless line_items_downloaded?
      end
    end

    # If line items are not downloaded, then attempt a download now (if this record was found to begin with).
    def line_items
      if line_items_downloaded?
        @line_items

      elsif bank_transaction_id =~ GUID_REGEX && @gateway
        # There is a bank_transaction_id so we can assume this record was loaded from Xero.
        # Let's attempt to download the line_item records (if there is a gateway)

        response = @gateway.get_bank_transaction(bank_transaction_id)
        raise BankTransactionNotFoundError, "Bank Transaction with ID #{bank_transaction_id} not found in Xero." unless response.success? && response.bank_transaction.is_a?(XeroGateway::BankTransaction)

        @line_items = response.bank_transaction.line_items
        @line_items_downloaded = true

        @line_items

      # Otherwise, this is a new bank transaction, so return the line_items reference.
      else
        @line_items
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.BankTransaction {
        b.BankTransactionID bank_transaction_id if bank_transaction_id
        b.Type type
        # b.CurrencyCode self.currency_code if self.currency_code
        contact.to_xml(b) if contact
        bank_account.to_xml(b, :name => 'BankAccount') if bank_account
        b.Date BankTransaction.format_date(date || Date.today)
        b.Status status if status
        b.Reference reference if reference
        b.IsReconciled true if self.is_reconciled
        b.LineItems {
          self.line_items.each do |line_item|
            line_item.to_xml(b)
          end
        }
        b.Url url if url
      }
    end

    def self.from_xml(bank_transaction_element, gateway = nil, options = {})
      bank_transaction = BankTransaction.new(options.merge({:gateway => gateway}))
      bank_transaction_element.children.each do |element|
        case(element.name)
          when "BankTransactionID" then bank_transaction.bank_transaction_id = element.text
          when "UpdatedDateUTC" then bank_transaction.updated_at = parse_date_time(element.text)
          when "Type" then bank_transaction.type = element.text
          # when "CurrencyCode" then invoice.currency_code = element.text
          when "Contact" then bank_transaction.contact = Contact.from_xml(element)
          when "BankAccount" then bank_transaction.bank_account = Account.from_xml(element)
          when "Date" then bank_transaction.date = parse_date(element.text)
          when "Status" then bank_transaction.status = element.text
          when "Reference" then bank_transaction.reference = element.text
          when "LineItems" then element.children.each {|line_item| bank_transaction.line_items_downloaded = true; bank_transaction.line_items << LineItem.from_xml(line_item) }
          when "Total" then bank_transaction.total = BigDecimal.new(element.text)
          when "SubTotal" then bank_transaction.sub_total = BigDecimal.new(element.text)
          when "TotalTax" then bank_transaction.total_tax = BigDecimal.new(element.text)
          # when "Total" then invoice.total = BigDecimal.new(element.text)
          # when "InvoiceID" then invoice.invoice_id = element.text
          # when "InvoiceNumber" then invoice.invoice_number = element.text
          # when "Payments" then element.children.each { | payment | invoice.payments << Payment.from_xml(payment) }
          # when "AmountDue" then invoice.amount_due = BigDecimal.new(element.text)
          # when "AmountPaid" then invoice.amount_paid = BigDecimal.new(element.text)
          # when "AmountCredited" then invoice.amount_credited = BigDecimal.new(element.text)
          # when "SentToContact" then invoice.sent_to_contact = (element.text.strip.downcase == "true")
          when "IsReconciled" then bank_transaction.is_reconciled = (element.text.strip.downcase == "true")
          when "Url" then bank_transaction.url = element.text
        end
      end
      bank_transaction
    end # from_xml

  end
end
