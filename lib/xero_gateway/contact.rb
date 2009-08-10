module XeroGateway
  class Contact
    include Dates
    
    class Error < RuntimeError; end
    class NoGatewayError < Error; end
    
    CONTACT_STATUS = {
      'ACTIVE' =>     'Active',
      'DELETED' =>    'Deleted'
    }
            
    # Xero::Gateway associated with this contact.
    attr_accessor :gateway
    
    attr_accessor :contact_id, :contact_number, :status, :name, :email, :addresses, :phones, :updated_at    
    
    def initialize(params = {})
      params = {}.merge(params)      
      params.each do |k,v|
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
    
    # General purpose create/save method.
    # If contact_id and contact_number are nil then create, otherwise, attempt to save.
    def save
      if contact_id.nil? && contact_number.nil?
        create
      else
        update
      end
    end
    
    # Creates this contact record (using gateway.create_contact) with the associated gateway.
    # If no gateway set, raise a Xero::Contact::NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway
      gateway.create_contact(self)
    end
    
    # Creates this contact record (using gateway.update_contact) with the associated gateway.
    # If no gateway set, raise a Xero::Contact::NoGatewayError exception.
    def update
      raise NoGatewayError unless gateway
      gateway.update_contact(self)
    end
        
    def to_xml(b = Builder::XmlMarkup.new)
      b.Contact {
        b.ContactID self.contact_id if self.contact_id
        b.ContactNumber self.contact_number if self.contact_number
        b.Name self.name
        b.EmailAddress self.email if self.email
        b.Addresses {
          addresses.each { |address| address.to_xml(b) }
        }
        b.Phones {
          phones.each { |phone| phone.to_xml(b) }
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
          when "Addresses" then element.children.each {|address_element| contact.addresses << Address.from_xml(address_element)}
          when "Phones" then element.children.each {|phone_element| contact.phones << Phone.from_xml(phone_element)}
        end
      end
      contact
    end
    
    def ==(other)
      [:contact_number, :status, :name, :email, :addresses, :phones].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end    
        
  end
end
