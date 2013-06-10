module XeroGateway::Payroll
  class SuperMembership
    
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :super_fund_id, :employee_number
    
     def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.SuperMembership {
      	b.SuperFundID self.super_fund_id if self.super_fund_id
        b.EmployeeNumber self.employee_number if self.employee_number
      }
    end
    
    def self.from_xml(super_membership_element, gateway = nil)
      super_membership = SuperMembership.new
      super_membership_element.children.each do |element|
        case(element.name)
          when "SuperFundID" then super_membership.super_fund_id = element.text
          when "EmployeeNumber" then  super_membership.employee_number = element.text
        end
      end
      super_membership
    end

    def ==(other)
      [ :super_fund_id, :employee_number ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
