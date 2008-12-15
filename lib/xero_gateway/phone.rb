module XeroGateway
  class Phone
    attr_accessor :phone_type, :number, :area_code, :country_code
    
    def initialize(params = {})
      params = {
        :phone_type => "DEFAULT"
      }.merge(params)
      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.Phone {
        b.PhoneType phone_type
        b.PhoneNumber number
        b.PhoneAreaCode area_code if area_code
        b.PhoneCountryCode country_code if country_code
      }
    end
    
    def self.from_xml(phone_element)
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
    
    def ==(other)
      [:phone_type, :number, :area_code, :country_code].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end    
  end
end