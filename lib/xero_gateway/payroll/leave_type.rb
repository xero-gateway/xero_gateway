module XeroGateway::Payroll
  class NoGatewayError < StandardError; end

  class LeaveType 
  
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors    
    attr_accessor :name, :type_of_units, :is_paid_leave, :show_on_payslip, :leave_type_id, :normal_entitlement, :leave_loading_rate
    
    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end 
    end

    def save
      raise NoGatewayError unless gateway

      pay_item = gateway.get_payroll_pay_items.response_item
      pay_item.gateway = gateway

      if leave_type_id
        pay_item.leave_types.delete_if {|obj| obj.leave_type_id == leave_type_id }
      end
      pay_item.leave_types << self

      pay_item.save
    end
    
    # Validate the LeaveType record according to what will be valid by the gateway.
    #
    # Usage:
    #  leave_type.valid?     # Returns true/false
    #
    #  Additionally sets leave_type.errors array to an array of field/error.
    # TO DO : others fields validation
    def valid?
      @errors = []
      
      if !leave_type_id.blank? && leave_type_id !~ GUID_REGEX
        @errors << ['employee_id', 'invalid ID']
      end
      
      if name.blank?
        @errors << ['name', "can't be blank"]
      end 
      
      if type_of_units.blank?
        @errors << ['type_of_units', "can't be blank"]
      end 
      
      if is_paid_leave.blank?
        @errors << ['is_paid_leave', "can't be blank"]
      end 
      
      if show_on_payslip.blank?
        @errors << ['show_on_payslip', "can't be blank"]
      end 
      
      @errors.size == 0
    end 
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.LeaveType {
      	b.Name self.name if self.name
        b.TypeOfUnits self.type_of_units if self.type_of_units
        b.IsPaidLeave self.is_paid_leave if self.is_paid_leave
        b.ShowOnPayslip self.show_on_payslip if self.show_on_payslip
        b.LeaveTypeID self.leave_type_id if self.leave_type_id
        b.NormalEntitlement self.normal_entitlement if self.normal_entitlement
        b.LeaveLoadingRate self.leave_loading_rate if self.leave_loading_rate
      }
    end
    
    def self.from_xml(leave_type_element, gateway = nil)
      leave_type = LeaveType.new
      leave_type_element.children.each do |element|
        case(element.name)
          when "Name" then leave_type.name = element.text
          when "TypeOfUnits" then leave_type.type_of_units = element.text
          when "IsPaidLeave" then leave_type.is_paid_leave = element.text
          when "ShowOnPayslip" then leave_type.show_on_payslip = element.text
          when "LeaveTypeID" then leave_type.leave_type_id = element.text
          when "NormalEntitlement" then leave_type.normal_entitlement = element.text
          when "LeaveLoadingRate" then leave_type.leave_loading_rate = element.text
        end 
      end 
      leave_type
    end 
    
    def ==(other) [ :name, :type_of_units, :is_paid_leave, :show_on_payslip, :leave_type_id, :normal_entitlement, :leave_loading_rate ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
