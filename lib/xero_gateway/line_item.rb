module XeroGateway
  class LineItem
    # All accessible fields
    attr_accessor :id, :description, :quantity, :unit_amount, :tax_type, :tax_amount, :line_amount, :account_code, :tracking_category, :tracking_option
    
    def initialize(params = {})
      params = {
        :quantity => 1
      }.merge(params)
      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end    

    def ==(other)
      return true
      equal = true
      [:description, :quantity, :unit_amount, :tax_type, :tax_amount, :line_amount, :account_code, :tracking_category, :tracking_option].each do |field|
        equal &&= (send(field) == other.send(field))
      end
      return equal
    end
  end
end
