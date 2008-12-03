module XeroGateway
  module Messages
    class AccountMessage      
      
      def self.build_xml(account)
        b = Builder::XmlMarkup.new
        
        b.Account {
          b.Code account.code
          b.Name account.name
          b.Type account.type
          b.TaxType account.tax_type
          b.Description account.description
        }
      end
      
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
    end
  end
end