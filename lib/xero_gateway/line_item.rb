module XeroGateway
  class LineItem
    include Money

    # All accessible fields
    attr_accessor :line_item_id, :description, :quantity, :unit_amount, :tax_type, :tax_amount, :line_amount, :account_code, :tracking_category, :tracking_option
    
    def initialize(params = {})
      @quantity = 1
      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end    
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.LineItem {
        b.Description description
        b.Quantity quantity if quantity
        b.UnitAmount LineItem.format_money(unit_amount)
        b.TaxType tax_type if tax_type
        b.TaxAmount LineItem.format_money(tax_amount) if tax_amount
        b.LineAmount LineItem.format_money(line_amount)
        b.AccountCode account_code if account_code
        b.Tracking {
          b.TrackingCategory {
            b.Name tracking_category
            b.Option tracking_option
          }
        }      
      }
    end
    
    def self.from_xml(line_item_element)
      line_item = LineItem.new
      line_item_element.children.each do |element|
        case(element.name)
          when "LineItemID" then line_item.line_item_id = element.text
          when "Description" then line_item.description = element.text
          when "Quantity" then line_item.quantity = element.text.to_i
          when "UnitAmount" then line_item.unit_amount = BigDecimal.new(element.text)
          when "TaxType" then line_item.tax_type = element.text
          when "TaxAmount" then line_item.tax_amount = BigDecimal.new(element.text)
          when "LineAmount" then line_item.line_amount = BigDecimal.new(element.text)
          when "AccountCode" then line_item.account_code = element.text
          when "Tracking" then
          if element.elements['TrackingCategory']
            line_item.tracking_category = element.elements['TrackingCategory/Name'].text
            line_item.tracking_option = element.elements['TrackingCategory/Option'].text
          end
        end
      end
      line_item
    end    

    def ==(other)
      [:description, :quantity, :unit_amount, :tax_type, :tax_amount, :line_amount, :account_code, :tracking_category, :tracking_option].each do |field|
        puts field if send(field) != other.send(field) 
        return false if send(field) != other.send(field)
      end
      return true
    end
  end  
end
