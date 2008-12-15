module XeroGateway
  class Invoice
    include Dates
    include Money
    
    # All accessible fields
    attr_accessor :invoice_id, :invoice_number, :invoice_type, :invoice_status, :date, :due_date, :reference, :tax_inclusive, :includes_tax, :sub_total, :total_tax, :total, :line_items, :contact
    
    def initialize(params = {})
      params = {
        :contact => Contact.new,
        :date => Time.now,
        :includes_tax => true,
        :tax_inclusive => true
      }.merge(params)
      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
      
      @line_items ||= []
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
    
    def to_xml
      b = Builder::XmlMarkup.new
      
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
    
    def self.from_xml(invoice_element)        
      invoice = Invoice.new
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
        end
      end      
      invoice
    end    
  end
end
