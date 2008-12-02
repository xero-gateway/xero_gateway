module XeroGateway
  module Messages
    class AccountMessage      
      
      # Take an Account element and convert it into an Account object
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
      
      private
      
      def self.parse_line_item(line_item_element)
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
    end
  end
end