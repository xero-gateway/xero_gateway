module XeroGateway
  class Payment
    include Money
    include Dates

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # All accessible fields
    attr_accessor :date, :amount
        
    def initialize(params = {})
      @errors ||= []
            
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def self.from_xml(payment_element)
      payment = Payment.new
      payment_element.children.each do | element |
        case element.name
          when 'Date' then    payment.date = parse_date_time(element.text)
          when 'Amount' then  payment.amount = BigDecimal.new(element.text)
        end    
      end
      payment
    end 
    
    def ==(other)
      [:date, :amount].each do |field|
        puts field if send(field) != other.send(field) 
        return false if send(field) != other.send(field)
      end
      return true
    end
    

  end
end