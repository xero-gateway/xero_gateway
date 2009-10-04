module XeroGateway
  class TaxRate
    
    unless defined? ATTRS
      ATTRS = {
        "Name"                  => :string, 
        "TaxType"               => :string,
        "CanApplyToAssets"      => :boolean,
        "CanApplyToEquity"      => :boolean,
        "CanApplyToExpenses"    => :boolean,
        "CanApplyToLiabilities" => :boolean,
        "CanApplyToRevenue"     => :boolean,
        "DisplayTaxRate"        => :float,
        "EffectiveRate"         => :float
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
      
      b.TaxRate do
        ATTRS.keys.each do |attr|
          eval("b.#{attr} '#{self.send(attr.underscore.to_sym)}'")
        end
      end
    end
    
    def self.from_xml(tax_rate_element)
      returning TaxRate.new do |tax_rate|
        tax_rate_element.children.each do |element|
        
          attribute             = element.name
          underscored_attribute = element.name.underscore
        
          raise "Unknown attribute: #{attribute}" unless ATTRS.keys.include?(attribute)
        
          case (ATTRS[attribute])
            when :boolean then  tax_rate.send("#{underscored_attribute}=", (element.text == "true"))
            when :float   then  tax_rate.send("#{underscored_attribute}=", element.text.to_f)
            else                tax_rate.send("#{underscored_attribute}=", element.text)
          end
          
        end
      end
    end
    
  end
end