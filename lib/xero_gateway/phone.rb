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
    
    def ==(other)
      [:phone_type, :number, :area_code, :country_code].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end    
  end
end