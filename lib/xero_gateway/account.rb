module XeroGateway
  class Account
    attr_accessor :code, :name, :type, :tax_type, :description
    
    def initialize(params = {})
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end
    
    def ==(other)
      [:code, :name, :type, :tax_type, :description].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
    
    def to_xml
      b = Builder::XmlMarkup.new
      
      b.Account {
        b.Code self.code
        b.Name self.name
        b.Type self.type
        b.TaxType self.tax_type
        b.Description self.description
      }
    end
    
    def self.from_xml(account_element)
      account = Account.new
      account_element.children.each do |element|
        case(element.name)
          when "Code" then account.code = element.text
          when "Name" then account.name = element.text
          when "Type" then account.type = element.text
          when "TaxType" then account.tax_type = element.text
          when "Description" then account.description = element.text
        end
      end      
      account
    end
    
  end
end