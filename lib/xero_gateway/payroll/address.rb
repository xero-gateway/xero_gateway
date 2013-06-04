module XeroGateway::Payroll
  class Address
    # include Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    # Xero::Gateway associated with this employee.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :address_line1, :address_line2, :address_line3, :address_line4, :city, :country, :postal_code, :region

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.HomeAddress {
      	b.AddressLine1 self.address_line1 if self.address_line1
        b.AddressLine2 self.address_line2 if self.address_line2
        b.AddressLine3 self.address_line3 if self.address_line3
        b.AddressLine4 self.address_line4 if self.address_line4
        b.City self.city if self.city
        b.Region self.region if self.region
        b.PostalCode self.postal_code if self.postal_code
        b.Country self.country if self.country
      }
    end
    
    # Should add other fields based on Pivotal: 49575441
    def self.from_xml(address_element, gateway = nil)
      address = Address.new
      address_element.children.each do |element|
      	puts "#{element.name}"
        case(element.name)
          when "AddressLine1" then address.address_line1 = element.text
          when "AddressLine2" then address.address_line2 = element.text
          when "AddressLine3" then address.address_line3 = element.text
          when "AddressLine4" then address.address_line4 = element.text
          when "City" then address.city = element.text
          when "Region" then address.region = element.text
          when "PostalCode" then address.postal_code = element.text
          when "Country" then address.country = element.text
        end
      end
      address
    end

    def ==(other)
      [ :address_line1, :address_line2, :address_line3, :address_line4, :city, :country, :postal_code, :region ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
