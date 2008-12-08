module XeroGateway
  class Error
    attr_accessor :description, :date_time, :type, :message
    
    def initialize(params = {})
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end
    
    def ==(other)
      [:description, :date_time, :type, :message].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end