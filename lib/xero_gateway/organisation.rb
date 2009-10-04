module XeroGateway
  class Organisation
    
    unless defined? ATTRS
      ATTRS = {
        "Name" 	       => :string,     # Display name of organisation shown in Xero
        "LegalName"    => :string,	   # Organisation name shown on Reports
        "PaysTax" 	   => :boolean,    # Boolean to describe if organisation is registered with a local tax authority i.e. true, false
        "Version"   	 => :string,     # See Version Types
        "BaseCurrency" => :string      # Default currency for organisation. See Currency types
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
      
      b.Organisation do
        ATTRS.keys.each do |attr|
          eval("b.#{attr} '#{self.send(attr.underscore.to_sym)}'")
        end
      end
    end
    
    def self.from_xml(organisation_element)
      returning Organisation.new do |org|
        organisation_element.children.each do |element|
        
          attribute             = element.name
          underscored_attribute = element.name.underscore
        
          raise "Unknown attribute: #{attribute}" unless ATTRS.keys.include?(attribute)
        
          case (ATTRS[attribute])
            when :boolean then  org.send("#{underscored_attribute}=", (element.text == "true"))
            when :float   then  org.send("#{underscored_attribute}=", element.text.to_f)
            else                org.send("#{underscored_attribute}=", element.text)
          end
          
        end
      end
    end
    
  end
end