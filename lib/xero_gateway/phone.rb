module XeroGateway
  class Phone
    
    PHONE_TYPE = {
      'DEFAULT' =>    'Default',
      'DDI' =>        'Direct Dial-In',
      'MOBILE' =>     'Mobile',
      'FAX' =>        'Fax'
    } unless defined?(PHONE_TYPE)
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :phone_type, :number, :area_code, :country_code
    
    def initialize(params = {})
      @errors ||= []
      
      params = {
        :phone_type => "DEFAULT"
      }.merge(params)
      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    # Validate the Phone record according to what will be valid by the gateway.
    #
    # Usage: 
    #  phone.valid?     # Returns true/false
    #  
    #  Additionally sets phone.errors array to an array of field/error.
    def valid?
      @errors = []
            
      unless number
        @errors << ['number', "can't be blank"]
      else
        @errors << ['number', "must 50 characters or less"] if number.length > 50
      end
      
      if phone_type && !PHONE_TYPE[phone_type]
        @errors << ['phone_type', "must be one of #{PHONE_TYPE.keys.join('/')}"]
      end
      
      @errors.size == 0
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
