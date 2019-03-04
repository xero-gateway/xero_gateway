module XeroGateway
  class CreditNote
    include Dates
    include Money
    include LineItemCalculations

    CREDIT_NOTE_TYPE = {
      'ACCRECCREDIT' =>           'Accounts Receivable',
      'ACCPAYCREDIT' =>           'Accounts Payable'
    } unless defined?(CREDIT_NOTE_TYPE)

    LINE_AMOUNT_TYPES = {
      "Inclusive" =>        'CreditNote lines are inclusive tax',
      "Exclusive" =>        'CreditNote lines are exclusive of tax (default)',
      "NoTax"     =>        'CreditNotes lines have no tax'
    } unless defined?(LINE_AMOUNT_TYPES)

    CREDIT_NOTE_STATUS = {
      'AUTHORISED' =>       'Approved credit_notes awaiting payment',
      'DELETED' =>          'Draft credit_notes that are deleted',
      'DRAFT' =>            'CreditNotes saved as draft or entered via API',
      'PAID' =>             'CreditNotes approved and fully paid',
      'SUBMITTED' =>        'CreditNotes entered by an employee awaiting approval',
      'VOID' =>             'Approved credit_notes that are voided'
    } unless defined?(CREDIT_NOTE_STATUS)

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    # Xero::Gateway associated with this credit_note.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # Represents whether the line_items have been downloaded when getting from GET /API.XRO/2.0/CreditNotes
    attr_accessor :line_items_downloaded

    # All accessible fields
    attr_accessor :credit_note_id, :credit_note_number, :type, :status, :date, :reference, :line_amount_types, :currency_code, :payments, :fully_paid_on, :amount_credited
    attr_writer :line_items, :contact

    def initialize(params = {})
      @errors ||= []
      @payments ||= []

      # Check if the line items have been downloaded.
      @line_items_downloaded = (params.delete(:line_items_downloaded) == true)

      params = {
        :line_amount_types => "Inclusive"
      }.merge(params)

      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @line_items ||= []
    end

    # Validate the Address record according to what will be valid by the gateway.
    #
    # Usage:
    #  address.valid?     # Returns true/false
    #
    #  Additionally sets address.errors array to an array of field/error.
    def valid?
      @errors = []

      if !credit_note_id.nil? && credit_note_id !~ GUID_REGEX
        @errors << ['credit_note_id', 'must be blank or a valid Xero GUID']
      end

      if status && !CREDIT_NOTE_STATUS[status]
        @errors << ['status', "must be one of #{CREDIT_NOTE_STATUS.keys.join('/')}"]
      end

      if line_amount_types && !LINE_AMOUNT_TYPES[line_amount_types]
        @errors << ['line_amount_types', "must be one of #{LINE_AMOUNT_TYPES.keys.join('/')}"]
      end

      unless date
        @errors << ['credit_note_date', "can't be blank"]
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

    # Helper method to create the associated contact object.
    def build_contact(params = {})
      self.contact = gateway ? gateway.build_contact(params) : Contact.new(params)
    end

    def contact
      @contact ||= build_contact
    end

    # Helper method to check if the credit_note is accounts payable.
    def accounts_payable?
      type == 'ACCPAYCREDIT'
    end

    # Helper method to check if the credit_note is accounts receivable.
    def accounts_receivable?
      type == 'ACCRECCREDIT'
    end

    # Whether or not the line_items have been downloaded (GET/credit_notes does not download line items).
    def line_items_downloaded?
      @line_items_downloaded
    end

    # If line items are not downloaded, then attempt a download now (if this record was found to begin with).
    def line_items
      if line_items_downloaded?
        @line_items

      # There is an credit_note_is so we can assume this record was loaded from Xero.
      # attempt to download the line_item records.
      elsif credit_note_id =~ GUID_REGEX
        raise NoGatewayError unless @gateway

        response = @gateway.get_credit_note(credit_note_id)
        raise CreditNoteNotFoundError, "CreditNote with ID #{credit_note_id} not found in Xero." unless response.success? && response.credit_note.is_a?(XeroGateway::CreditNote)

        @line_items = response.credit_note.line_items
        @line_items_downloaded = true

        @line_items

      # Otherwise, this is a new credit_note, so return the line_items reference.
      else
        @line_items
      end
    end

    def ==(other)
      ["credit_note_number", "type", "status", "reference", "currency_code", "line_amount_types", "contact", "line_items"].each do |field|
        return false if send(field) != other.send(field)
      end

      ["date"].each do |field|
        return false if send(field).to_s != other.send(field).to_s
      end
      return true
    end

    # Creates this credit_note record (using gateway.create_credit_note) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway
      gateway.create_credit_note(self)
    end

    # Alias create as save as this is currently the only write action.
    alias_method :save, :create

    def to_xml(b = Builder::XmlMarkup.new)
      b.CreditNote {
        b.Type self.type
        contact.to_xml(b)
        b.Date CreditNote.format_date(self.date || Date.today)
        b.Status self.status if self.status
        b.CreditNoteNumber self.credit_note_number if credit_note_number
        b.Reference self.reference if self.reference
        b.CurrencyCode self.currency_code if self.currency_code
        b.LineAmountTypes self.line_amount_types
        b.LineItems {
          self.line_items.each do |line_item|
            line_item.to_xml(b)
          end
        }
      }
    end

    #TODO UpdatedDateUTC
    def self.from_xml(credit_note_element, gateway = nil, options = {})
      credit_note = CreditNote.new(options.merge({:gateway => gateway}))
      credit_note_element.children.each do |element|
        case(element.name)
          when "CreditNoteID" then credit_note.credit_note_id = element.text
          when "CreditNoteNumber" then credit_note.credit_note_number = element.text
          when "Type" then credit_note.type = element.text
          when "CurrencyCode" then credit_note.currency_code = element.text
          when "Contact" then credit_note.contact = Contact.from_xml(element)
          when "Date" then credit_note.date = parse_date(element.text)
          when "Status" then credit_note.status = element.text
          when "Reference" then credit_note.reference = element.text
          when "LineAmountTypes" then credit_note.line_amount_types = element.text
          when "LineItems" then element.children.each {|line_item| credit_note.line_items_downloaded = true; credit_note.line_items << LineItem.from_xml(line_item) }
          when "SubTotal" then credit_note.sub_total = BigDecimal(element.text)
          when "TotalTax" then credit_note.total_tax = BigDecimal(element.text)
          when "Total" then credit_note.total = BigDecimal(element.text)
          when "Payments" then element.children.each { | payment | credit_note.payments << Payment.from_xml(payment) }
          when "AmountDue" then credit_note.amount_due = BigDecimal(element.text)
          when "AmountPaid" then credit_note.amount_paid = BigDecimal(element.text)
          when "AmountCredited" then credit_note.amount_credited = BigDecimal(element.text)
        end
      end
      credit_note
    end
  end
end
