module XeroGateway
  module Money
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def format_money(amount)
        if amount.class == BigDecimal
          return amount.to_s("F")
        end
        return amount
      end
    end
  end
end
