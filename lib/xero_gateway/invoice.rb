module XeroGateway
  class Invoice
    include Dates
    include Money
    include LineItemCalculations
    
    INVOICE_TYPE = {
      'ACCREC' =>           'Accounts Receivable',
      'ACCPAY' =>           'Accounts Payable'
    } unless defined?(INVOICE_TYPE)
    
    LINE_AMOUNT_TYPES = {
      "Inclusive" =>        'Invoice lines are inclusive tax',
      "Exclusive" =>        'Invoice lines are exclusive of tax (default)',
      "NoTax"     =>        'Invoices lines have no tax'
    } unless defined?(LINE_AMOUNT_TYPES)
    
    INVOICE_STATUS = {
      'AUTHORISED' =>       'Approved invoices awaiting payment',
      'DELETED' =>          'Draft invoices that are deleted',
      'DRAFT' =>            'Invoices saved as draft or entered via API',
      'PAID' =>             'Invoices approved and fully paid',
      'SUBMITTED' =>        'Invoices entered by an employee awaiting approval',
      'VOID' =>             'Approved invoices that are voided'
    } unless defined?(INVOICE_STATUS)
    
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
        
    # Xero::Gateway associated with this invoice.
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    # Or errors that were within the XML payload from Xero
    attr_accessor :errors

    # Represents whether the line_items have been downloaded when getting from GET /API.XRO/2.0/INVOICES
    attr_accessor :line_items_downloaded
  
    # All accessible fields
    attr_accessor :invoice_id, :invoice_number, :invoice_type, :invoice_status, :date, :due_date, :reference, :branding_theme_id, :line_amount_types, :currency_code, :line_items, :contact, :payments, :fully_paid_on, :amount_due, :amount_paid, :amount_credited, :sent_to_contact, :url

    def initialize(params = {})
      @errors ||= []
      @payments ||= []
      
      # Check if the line items have been downloaded.
      @line_items_downloaded = (params.delete(:line_items_downloaded) == true)
      
      params = {
        :line_amount_types => "Exclusive"
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
      
      if !INVOICE_TYPE[invoice_type]
        @errors << ['invoice_type', "must be one of #{INVOICE_TYPE.keys.join('/')}"]
      end

      if !invoice_id.nil? && invoice_id !~ GUID_REGEX
        @errors << ['invoice_id', 'must be blank or a valid Xero GUID']
      end
            
      if invoice_status && !INVOICE_STATUS[invoice_status]
        @errors << ['invoice_status', "must be one of #{INVOICE_STATUS.keys.join('/')}"]
      end

      if line_amount_types && !LINE_AMOUNT_TYPES[line_amount_types]
        @errors << ['line_amount_types', "must be one of #{LINE_AMOUNT_TYPES.keys.join('/')}"]
      end
      
      unless date
        @errors << ['invoice_date', "can't be blank"]
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
    
    # Helper method to check if the invoice is accounts payable.
    def accounts_payable?
      invoice_type == 'ACCPAY'
    end
    
    # Helper method to check if the invoice is accounts receivable.
    def accounts_receivable?
      invoice_type == 'ACCREC'
    end
    
    # Whether or not the line_items have been downloaded (GET/invoices does not download line items).
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

      elsif invoice_id =~ GUID_REGEX && @gateway
        # There is an invoice_id so we can assume this record was loaded from Xero.
        # Let's attempt to download the line_item records (if there is a gateway)
        response = @gateway.get_invoice(invoice_id)
        raise InvoiceNotFoundError, "Invoice with ID #{invoice_id} not found in Xero." unless response.success? && response.invoice.is_a?(XeroGateway::Invoice)
        
        @line_items = response.invoice.line_items
        @line_items_downloaded = true
        
        @line_items
        
      # Otherwise, this is a new invoice, so return the line_items reference.
      else
        @line_items
      end
    end
    
    def ==(other)
      ["invoice_number", "invoice_type", "invoice_status", "reference", "currency_code", "line_amount_types", "contact", "line_items"].each do |field|
        return false if send(field) != other.send(field)
      end
      
      ["date", "due_date"].each do |field|
        return false if send(field).to_s != other.send(field).to_s
      end
      return true
    end
    
    # General purpose create/save method.
    # If invoice_id is nil then create, otherwise, attempt to save.
    def save
      if invoice_id.nil?
        create
      else
        update
      end
    end
    
    # Creates this invoice record (using gateway.create_invoice) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway
      gateway.create_invoice(self)
    end
    
    # Updates this invoice record (using gateway.update_invoice) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def update
      raise NoGatewayError unless gateway
      gateway.update_invoice(self)
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.Invoice {
        b.InvoiceID self.invoice_id if self.invoice_id
        b.InvoiceNumber self.invoice_number if invoice_number
        b.Type self.invoice_type
        b.CurrencyCode self.currency_code if self.currency_code
        contact.to_xml(b)
        b.Date Invoice.format_date(self.date || Date.today)
        b.DueDate Invoice.format_date(self.due_date) if self.due_date
        b.Status self.invoice_status if self.invoice_status
        b.Reference self.reference if self.reference
        b.BrandingThemeID self.branding_theme_id if self.branding_theme_id
        b.LineAmountTypes self.line_amount_types
        b.LineItems {
          self.line_items.each do |line_item|
            line_item.to_xml(b)
          end
        }
        b.Url url if url
      }
    end
    
    #TODO UpdatedDateUTC
    def self.from_xml(invoice_element, gateway = nil, options = {})
      invoice = Invoice.new(options.merge({:gateway => gateway}))
      invoice_element.children.each do |element|
        case(element.name)
          when "InvoiceID" then invoice.invoice_id = element.text
          when "InvoiceNumber" then invoice.invoice_number = element.text            
          when "Type" then invoice.invoice_type = element.text
          when "CurrencyCode" then invoice.currency_code = element.text
          when "Contact" then invoice.contact = Contact.from_xml(element)
          when "Date" then invoice.date = parse_date(element.text)
          when "DueDate" then invoice.due_date = parse_date(element.text)
          when "Status" then invoice.invoice_status = element.text
          when "Reference" then invoice.reference = element.text
          when "BrandingThemeID" then invoice.branding_theme_id = element.text
          when "LineAmountTypes" then invoice.line_amount_types = element.text
          when "LineItems" then element.children.each {|line_item| invoice.line_items_downloaded = true; invoice.line_items << LineItem.from_xml(line_item) }
          when "SubTotal" then invoice.sub_total = BigDecimal.new(element.text)
          when "TotalTax" then invoice.total_tax = BigDecimal.new(element.text)
          when "Total" then invoice.total = BigDecimal.new(element.text)
          when "InvoiceID" then invoice.invoice_id = element.text
          when "InvoiceNumber" then invoice.invoice_number = element.text
          when "Payments" then element.children.each { | payment | invoice.payments << Payment.from_xml(payment) }
          when "AmountDue" then invoice.amount_due = BigDecimal.new(element.text)
          when "AmountPaid" then invoice.amount_paid = BigDecimal.new(element.text)
          when "AmountCredited" then invoice.amount_credited = BigDecimal.new(element.text)
          when "SentToContact" then invoice.sent_to_contact = (element.text.strip.downcase == "true")
          when "Url" then invoice.url = element.text
          when "ValidationErrors" then invoice.errors = element.children.map { |error| Error.parse(error) }
        end
      end
      invoice
    end
  end
end
