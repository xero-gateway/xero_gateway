module XeroGateway
  class Contact
    include Dates
    
    attr_accessor :contact_id, :contact_number, :status, :name, :email, :addresses, :phones, :updated_at
    
    def initialize(params = {})
      params = {}.merge(params)      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end

      @phones ||= []
      @addresses ||= []
    end
    
    def address=(address)
      self.addresses = [address]
    end
    
    def address
      self.addresses[0] ||= Address.new
    end
    
    def phone=(phone)
      self.phones = [phone]
    end
    
    def phone
      if @phones.size > 1
        @phones.detect {|p| p.phone_type == 'DEFAULT'} || phones[0]
      else
        @phones[0] ||= Phone.new
      end
    end
    
    def ==(other)
      [:contact_number, :status, :name, :email, :addresses, :phones].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
    
    def to_xml
      b = Builder::XmlMarkup.new
      
      b.Contact {
        b.ContactID self.contact_id if self.contact_id
        b.ContactNumber self.contact_number if self.contact_number
        b.Name self.name
        b.EmailAddress self.email if self.email
        b.Addresses {
          self.addresses.each do |address|
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
          self.phones.each do |phone|
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
          when "ContactID" then contact.contact_id = element.text
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
