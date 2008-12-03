module XeroGateway
  module Messages
    class TrackingCategoryMessage      
      
      def self.build_xml(tracking_category)
        b = Builder::XmlMarkup.new
        
        b.TrackingCategory {
          b.Name tracking_category.name
          b.Options {
            tracking_category.options.each do |option|
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
end