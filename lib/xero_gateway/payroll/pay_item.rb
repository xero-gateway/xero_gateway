module XeroGateway::Payroll
  class PayItem
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :earnings_rates, :deduction_types, :leave_types, :reimbursement_types
    
    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
      
      @earnings_rates ||= []
      @deduction_types ||= []
      @leave_types ||= []
      @reimbursement_types ||= []
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.PayItems {
      	b.EarningsRates{
      	  self.earnings_rates.each do |earning_rate|
      	    earning_rate.to_xml(b)
      	  end 
      	} unless self.earnings_rates.blank?
      	b.DeductionTypes{
      	  self.deduction_types.each do |deduction_type|
      	    deduction_type.to_xml(b)
      	  end 
      	} unless self.deduction_types.blank?
      	b.LeaveTypes{
      	  self.leave_types.each do |leave_type|
      	    leave_type.to_xml(b)
      	  end 
      	} unless self.leave_types.blank?      	
      	b.ReimbursementTypes{
      	  self.reimbursement_types.each do |reimbursement_type|
      	    reimbursement_type.to_xml(b)
      	  end 
      	} unless self.reimbursement_types.blank?      	
      }
    end
    
    def self.from_xml(pay_item_element, gateway = nil)
      pay_item = PayItem.new
      pay_item_element.children.each do |element|  
        case (element.name)
          when "EarningsRates" then element.children.each{|child| pay_item.earnings_rates << EarningsRate.from_xml(child, gateway)}
          when "DeductionTypes" then element.children.each{|child| pay_item.deduction_types << DeductionType.from_xml(child, gateway)}
          when "LeaveTypes" then element.children.each{|child| pay_item.leave_types << LeaveType.from_xml(child, gateway)}
          when "ReimbursementTypes" then element.children.each{|child| pay_item.reimbursement_types << ReimbursementType.from_xml(child, gateway)}
        end 
      end 
      pay_item
    end 
    
    def ==(other) [ :earnings_rates, :deduction_types, :leave_types, :reimbursement_types ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end 
