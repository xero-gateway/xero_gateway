module XeroGateway
  class Invoice
    include Dates
    include Money
    
    class Error < RuntimeError; end
    class NoGatewayError < Error; end
    class InvalidLineItemError < Error; end
    
    INVOICE_TYPE = {
      'ACCREC' =>           'Accounts Receivable',
      'ACCPAY' =>           'Accounts Payable'
    } unless defined?(INVOICE_TYPE)
    
    INVOICE_STATUS = {
      'AUTHORISED' =>       'Approved invoices awaiting payment',
      'DELETED' =>          'Draft invoices that are deleted',
      'DRAFT' =>            'Invoices saved as draft or entered via API',
      'PAID' =>             'Invoices approved and fully paid',
      'SUBMITTED' =>        'Invoices entered by an employee awaiting approval',
      'VOID' =>             'Approved invoices that are voided'
    } unless defined?(INVOICE_STATUS)
        
    # Xero::Gateway associated with this invoice.
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
  
    # All accessible fields
    attr_accessor :invoice_id, :invoice_number, :invoice_type, :invoice_status, :date, :due_date, :reference, :tax_inclusive, :includes_tax, :line_items, :contact, :payments, :fully_paid_on, :amount_due, :amount_paid, :amount_credited
    
    def initialize(params = {})
      @errors ||= []
      @payments ||= []
      
      params = {
        :date => Time.now,
        :includes_tax => true,
        :tax_inclusive => true
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
      
      if !invoice_id.nil? && invoice_id !~ GUID_REGEX
        @errors << ['invoice_id', 'must be blank or a valid Xero GUID']
      end
            
      if invoice_status && !INVOICE_STATUS[invoice_status]
        @errors << ['invoice_status', "must be one of #{INVOICE_STATUS.keys.join('/')}"]
      end
      
      unless invoice_number
        @errors << ['invoice_number', "can't be blank"]
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
    
    # Helper method to create a new associated line_item.
    # Usage:
    #   invoice.add_line_item({:description => "Bob's Widgets", :quantity => 1, :unit_amount => 120})
    def add_line_item(params = {})
      line_item = nil
      case params
        when Hash then      line_item = LineItem.new(params)
        when LineItem then  line_item = params
        else                raise InvalidLineItemError
      end
      
      @line_items << line_item
      
      line_item
    end
    
    # Deprecated (but API for setter remains).
    #
    # As sub_total must equal SUM(line_item.line_amount) for the API call to pass, this is now
    # automatically calculated in the sub_total method.
    def sub_total=(value)
    end
    
    # Calculate the sub_total as the SUM(line_item.line_amount).
    def sub_total
      line_items.inject(BigDecimal.new('0')) { | sum, line_item | sum + BigDecimal.new(line_item.line_amount.to_s) }
    end
    
    # Deprecated (but API for setter remains).
    #
    # As total_tax must equal SUM(line_item.tax_amount) for the API call to pass, this is now
    # automatically calculated in the total_tax method.
    def total_tax=(value)
    end
    
    # Calculate the total_tax as the SUM(line_item.tax_amount).
    def total_tax
      line_items.inject(BigDecimal.new('0')) { | sum, line_item | sum + BigDecimal.new(line_item.tax_amount.to_s) }
    end
    
    # Deprecated (but API for setter remains).
    #
    # As total must equal sub_total + total_tax for the API call to pass, this is now
    # automatically calculated in the total method.
    def total=(value)
    end
    
    # Calculate the toal as sub_total + total_tax.
    def total
      sub_total + total_tax
    end
    
    # Helper method to check if the invoice is accounts payable.
    def accounts_payable?
      invoice_type == 'ACCPAY'
    end
    
    # Helper method to check if the invoice is accounts receivable.
    def accounts_receivable?
      invoice_type == 'ACCREC'
    end
    
    def ==(other)
      ["invoice_number", "invoice_type", "invoice_status", "reference", "tax_inclusive", "includes_tax", "sub_total", "total_tax", "total", "contact", "line_items"].each do |field|
        return false if send(field) != other.send(field)
      end
      ["date", "due_date"].each do |field|
        return false if send(field).to_s != other.send(field).to_s
      end
      return true
    end
    
    # General purpose createsave method.
    # If contact_id and contact_number are nil then create, otherwise, attempt to save.
    def save
      create
    end
    
    # Creates this invoice record (using gateway.create_invoice) with the associated gateway.
    # If no gateway set, raise a Xero::Invoice::NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway
      gateway.create_invoice(self)
    end
    
    # Alias create as save as this is currently the only write action.
    alias_method :save, :create
        
    def to_xml(b = Builder::XmlMarkup.new)
      b.Invoice {
        b.InvoiceType self.invoice_type
        contact.to_xml(b)
        b.InvoiceDate Invoice.format_date_time(self.date)
        b.DueDate Invoice.format_date_time(self.due_date) if self.due_date
        b.InvoiceNumber self.invoice_number
        b.Reference self.reference if self.reference
        b.TaxInclusive self.tax_inclusive if self.tax_inclusive
        b.IncludesTax self.includes_tax
        b.SubTotal Invoice.format_money(self.sub_total) if self.sub_total
        b.TotalTax Invoice.format_money(self.total_tax) if self.total_tax
        b.Total Invoice.format_money(self.total) if self.total
        b.LineItems {
          self.line_items.each do |line_item|
            line_item.to_xml(b)
          end
        }
      }
    end
    
    def self.from_xml(invoice_element, gateway = nil)
      invoice = Invoice.new(:gateway => gateway)
      invoice_element.children.each do |element|
        case(element.name)
          when "InvoiceStatus" then invoice.invoice_status = element.text
          when "InvoiceID" then invoice.invoice_id = element.text
          when "InvoiceNumber" then invoice.invoice_number = element.text            
          when "InvoiceType" then invoice.invoice_type = element.text
          when "InvoiceDate" then invoice.date = parse_date_time(element.text)
          when "DueDate" then invoice.due_date = parse_date_time(element.text)
          when "Reference" then invoice.reference = element.text
          when "TaxInclusive" then invoice.tax_inclusive = (element.text == "true")
          when "IncludesTax" then invoice.includes_tax = (element.text == "true")
          when "SubTotal" then invoice.sub_total = BigDecimal.new(element.text)
          when "TotalTax" then invoice.total_tax = BigDecimal.new(element.text)
          when "Total" then invoice.total = BigDecimal.new(element.text)
          when "Contact" then invoice.contact = Contact.from_xml(element)
          when "LineItems" then element.children.each {|line_item| invoice.line_items << LineItem.from_xml(line_item)}
          when "Payments" then element.children.each { | payment | invoice.payments << Payment.from_xml(payment) }
          when "FullyPaidOn" then invoice.fully_paid_on = parse_date_time(element.text)
          when "AmountDue" then invoice.amount_due = BigDecimal.new(element.text)
          when "AmountPaid" then invoice.amount_paid = BigDecimal.new(element.text)
          when "AmountCredited" then invoice.amount_credited = BigDecimal.new(element.text)
        end
      end      
      invoice
    end    
  end
end
