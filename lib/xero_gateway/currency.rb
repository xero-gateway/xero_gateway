module XeroGateway
  class Currency
    
    unless defined? ATTRS
      ATTRS = {
        "Code" 	       => :string,     # 3 letter alpha code for the currency – see list of currency codes
        "Description"  => :string, 	   # Name of Currency
      }
    end
    
    attr_accessor *ATTRS.keys.map(&:underscore)
    
    def initialize(params = {})
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def ==(other)
      ATTRS.keys.map(&:underscore).each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
    
    def to_xml
      b = Builder::XmlMarkup.new
      
      b.Currency do
        ATTRS.keys.each do |attr|
          eval("b.#{attr} '#{self.send(attr.underscore.to_sym)}'")
        end
      end
    end
    
    def self.from_xml(currency_element)
      returning Currency.new do |currency|
        currency_element.children.each do |element|
        
          attribute             = element.name
          underscored_attribute = element.name.underscore
        
          raise "Unknown attribute: #{attribute}" unless ATTRS.keys.include?(attribute)
        
          case (ATTRS[attribute])
            when :boolean then  currency.send("#{underscored_attribute}=", (element.text == "true"))
            when :float   then  currency.send("#{underscored_attribute}=", element.text.to_f)
            else                currency.send("#{underscored_attribute}=", element.text)
          end
          
        end
      end
    end
    
  end
end