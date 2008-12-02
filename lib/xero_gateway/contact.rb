module XeroGateway
  class Contact
    attr_accessor :id, :contact_number, :status, :name, :email, :addresses, :phones, :updated_at
    
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
      self.phones[0] ||= Phone.new
    end
    
    def ==(other)
      [:contact_number, :status, :name, :email, :addresses, :phones].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
