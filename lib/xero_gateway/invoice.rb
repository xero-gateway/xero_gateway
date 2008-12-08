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
        b.Contact {
          b.ContactID self.contact.contact_id if self.contact.contact_id
          b.Name self.contact.name
          b.EmailAddress self.contact.email if self.contact.email
          b.Addresses {
            self.contact.addresses.each do |address|
              b.Address {
                b.AddressType address.address_type
                b.AddressLine1 address.line_1 if address.line_1
                b.AddressLine2 address.line_2 if address.line_2
                b.AddressLine3 address.line_3 if address.line_3
                b.AddressLine4 address.line_4 if address.line_4
                b.City address.city if address.city
                b.Region address.region if address.region
                b.PostalCode address.post_code if address.post_code
                b.Country address.country if address.country
              }
            end
          }
          b.Phones {
            self.contact.phones.each do |phone|
              b.Phone {
                b.PhoneType phone.phone_type
                b.PhoneNumber phone.number
                b.PhoneAreaCode phone.area_code if phone.area_code
                b.PhoneCountryCode phone.country_code if phone.country_code
              }
            end
          }
        }
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
            b.LineItem {
              b.Description line_item.description
              b.Quantity line_item.quantity if line_item.quantity
              b.UnitAmount Invoice.format_money(line_item.unit_amount)
              b.TaxType line_item.tax_type if line_item.tax_type
              b.TaxAmount Invoice.format_money(line_item.tax_amount) if line_item.tax_amount
              b.LineAmount Invoice.format_money(line_item.line_amount)
              b.AccountCode line_item.account_code || 200
              b.Tracking {
                b.TrackingCategory {
                  b.Name line_item.tracking_category
                  b.Option line_item.tracking_option
                }
              }
            }              
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
          when "LineItems" then element.children.each {|line_item| invoice.line_items << parse_line_item(line_item)}
        end
      end      
      invoice
    end
    
    private
    
    def self.parse_line_item(line_item_element)
      line_item = LineItem.new
      line_item_element.children.each do |element|
        case(element.name)
          when "LineItemID" then line_item.line_item_id = element.text
          when "Description" then line_item.description = element.text
          when "Quantity" then line_item.quantity = element.text.to_i
          when "UnitAmount" then line_item.unit_amount = BigDecimal.new(element.text)
          when "TaxType" then line_item.tax_type = element.text
          when "TaxAmount" then line_item.tax_amount = BigDecimal.new(element.text)
          when "LineAmount" then line_item.line_amount = BigDecimal.new(element.text)
          when "AccountCode" then line_item.account_code = element.text
          when "Tracking" then
          if element.elements['TrackingCategory']
            line_item.tracking_category = element.elements['TrackingCategory/Name'].text
            line_item.tracking_option = element.elements['TrackingCategory/Option'].text
          end
        end
      end
      line_item
    end
  end
end
