module XeroGateway
  class TrackingCategory
    attr_accessor :name, :options
    
    def initialize(params = {})
      @options = []
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end
    
    def ==(other)
      [:name, :options].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end