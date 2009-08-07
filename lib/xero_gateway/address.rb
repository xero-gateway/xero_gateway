module XeroGateway
  class Address
    attr_accessor :address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country
    
    def initialize(params = {})
      params = {
        :address_type => "DEFAULT"
      }.merge(params)
      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
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
      
      string.split("\r\n").each_with_index do |line, index|
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
