module XeroGateway
  class Payment
    include Money
    include Dates

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # All accessible fields
    attr_accessor :payment_id, :date, :amount, :reference, :currency_rate
        
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
          when 'PaymentID'    then payment.payment_id = element.text
          when 'Date'         then payment.date = parse_date_time(element.text)
          when 'Amount'       then payment.amount = BigDecimal.new(element.text)
          when 'Reference'    then payment.reference = element.text
          when 'CurrencyRate' then payment.currency_rate = BigDecimal.new(element.text)
        end    
      end
      payment
    end 
    
    def ==(other)
      [:payment_id, :date, :amount].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
    

  end
end