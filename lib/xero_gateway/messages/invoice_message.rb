# Copyright (c) 2008 Tim Connor <tlconnor@gmail.com>
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

module XeroGateway
  module Messages
    class InvoiceMessage
      include Dates
      include Money
      
      def self.build_xml(invoice)
        b = Builder::XmlMarkup.new
        
        b.Invoice {
          b.InvoiceType invoice.invoice_type
          b.Contact {
            b.ContactID invoice.contact.id if invoice.contact.id
            b.Name invoice.contact.name
            b.EmailAddress invoice.contact.email if invoice.contact.email
            b.Addresses {
              invoice.contact.addresses.each do |address|
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
              invoice.contact.phones.each do |phone|
                b.Phone {
                  b.PhoneType phone.phone_type
                  b.PhoneNumber phone.number
                  b.PhoneAreaCode phone.area_code if phone.area_code
                  b.PhoneCountryCode phone.country_code if phone.country_code
                }
              end
            }
          }
          b.InvoiceDate format_date_time(invoice.date)
          b.DueDate format_date_time(invoice.due_date) if invoice.due_date
          b.InvoiceNumber invoice.invoice_number
          b.Reference invoice.reference if invoice.reference
          b.TaxInclusive invoice.tax_inclusive if invoice.tax_inclusive
          b.IncludesTax invoice.includes_tax
          b.SubTotal format_money(invoice.sub_total) if invoice.sub_total
          b.TotalTax format_money(invoice.total_tax) if invoice.total_tax
          b.Total format_money(invoice.total) if invoice.total
          b.LineItems {
            invoice.line_items.each do |line_item|
              b.LineItem {
                b.Description line_item.description
                b.Quantity line_item.quantity if line_item.quantity
                b.UnitAmount format_money(line_item.unit_amount)
                b.TaxType line_item.tax_type if line_item.tax_type
                b.TaxAmount format_money(line_item.tax_amount) if line_item.tax_amount
                b.LineAmount format_money(line_item.line_amount)
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
      
      # Take an Invoice element and convert it into an Invoice object
      def self.from_xml(invoice_element)        
        invoice = Invoice.new
        invoice_element.children.each do |element|
          case(element.name)
            when "InvoiceStatus" then invoice.invoice_status = element.text
            when "InvoiceID" then invoice.id = element.text
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
            when "Contact" then invoice.contact = ContactMessage.from_xml(element)
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
            when "LineItemID" then line_item.id = element.text
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
end