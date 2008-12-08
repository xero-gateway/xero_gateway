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
    
    def to_xml
      b = Builder::XmlMarkup.new
      
      b.TrackingCategory {
        b.Name self.name
        b.Options {
          self.options.each do |option|
            b.Option {
              b.Name option
            }
          end
        }
      }
    end
    
    def self.from_xml(tracking_category_element)
      tracking_category = TrackingCategory.new
      tracking_category_element.children.each do |element|
        case(element.name)
          when "Name" then tracking_category.name = element.text
          when "Options" then element.children.each {|option| tracking_category.options << option.children.first.text}
        end
      end
      tracking_category              
    end    
  end
end