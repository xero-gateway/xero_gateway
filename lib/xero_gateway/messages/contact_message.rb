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
    class ContactMessage
      include Dates
      
      def self.build_xml(contact)
        b = Builder::XmlMarkup.new
        
        b.Contact {
          b.ContactID contact.id if contact.id
          b.ContactNumber contact.contact_number if contact.contact_number
          b.Name contact.name
          b.EmailAddress contact.email if contact.email
          b.Addresses {
            contact.addresses.each do |address|
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
            contact.phones.each do |phone|
              b.Phone {
                b.PhoneType phone.phone_type
                b.PhoneNumber phone.number
                b.PhoneAreaCode phone.area_code if phone.area_code
                b.PhoneCountryCode phone.country_code if phone.country_code
              }
            end
          }
        }
      end
      
      # Take a Contact element and convert it into an Contact object
      def self.from_xml(contact_element)
        contact = Contact.new
        contact_element.children.each do |element|
          case(element.name)
            when "ContactID" then contact.id = element.text
            when "ContactNumber" then contact.contact_number = element.text
            when "ContactStatus" then contact.status = element.text
            when "Name" then contact.name = element.text
            when "EmailAddress" then contact.email = element.text
            when "Addresses" then element.children.each {|address| contact.addresses << parse_address(address)}
            when "Phones" then element.children.each {|phone| contact.phones << parse_phone(phone)}
          end
        end
        contact
      end
      
      private
      
      def self.parse_address(address_element)
        address = Address.new
        address_element.children.each do |element|
          case(element.name)
            when "AddressType" then address.address_type = element.text
            when "AddressLine1" then address.line_1 = element.text
            when "AddressLine2" then address.line_2 = element.text
            when "AddressLine3" then address.line_3 = element.text
            when "AddressLine4" then address.line_4 = element.text        
            when "City" then address.city = element.text
            when "Region" then address.region = element.text
            when "PostalCode" then address.post_code = element.text
            when "Country" then address.country = element.text
          end
        end
        address
      end
      
      def self.parse_phone(phone_element)
        phone = Phone.new
        phone_element.children.each do |element|
          case(element.name)
            when "PhoneType" then phone.phone_type = element.text
            when "PhoneNumber" then phone.number = element.text
            when "PhoneAreaCode" then phone.area_code = element.text
            when "PhoneCountryCode" then phone.country_code = element.text      
          end
        end
        phone
      end    
    end    
  end
end