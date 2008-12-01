module XeroGateway
  class Address
    attr_accessor :address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country
    
    def initialize(params = {})
      params = {
        :address_type => "DEFAULT"
      }.merge(params)
      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end
    
    def self.parse(string)
      address = Address.new
      
      string.split("\r\n").each_with_index do |line, index|
        address.instance_variable_set("@line_#{index+1}", line)
      end
      address
    end
    
    def ==(other)
      equal = true
      [:address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country].each do |field|
        equal &&= (send(field) == other.send(field))
      end
      return equal
    end
  end
end