module XeroGateway
  class Address
    
    ADDRESS_TYPE = {
      'STREET' =>     'Street',
      'POBOX' =>      'PO Box'
    } unless defined?(ADDRESS_TYPE)
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country
    
    def initialize(params = {})
      @errors ||= []
      
      params = {
        :address_type => "POBOX"
      }.merge(params)
      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    # Validate the Address record according to what will be valid by the gateway.
    #
    # Usage: 
    #  address.valid?     # Returns true/false
    #  
    #  Additionally sets address.errors array to an array of field/error.
    def valid?
      @errors = []
            
      if address_type && !ADDRESS_TYPE[address_type]
        @errors << ['address_type', "must be one of #{ADDRESS_TYPE.keys.join('/')} and is currently #{address_type}"]
      end
      
      @errors.size == 0
    end    
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.Address {
        b.AddressType address_type
        b.AddressLine1 line_1 if line_1
        b.AddressLine2 line_2 if line_2
        b.AddressLine3 line_3 if line_3
        b.AddressLine4 line_4 if line_4
        b.City city if city
        b.Region region if region
        b.PostalCode post_code if post_code
        b.Country country if country
      }
    end
    
    def self.from_xml(address_element)
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
    
    def self.parse(string)
      address = Address.new
      
      parts = string.split("\r\n")
      
      if(parts.size > 3)
        parts = [parts.shift, parts.shift, parts.shift, parts.join(", ")]
      end
      
      parts.each_with_index do |line, index|
        address.send("line_#{index+1}=", line)
      end
      address
    end
    
    def ==(other)
      [:address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
