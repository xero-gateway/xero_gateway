module XeroGateway::Payroll
  class LeaveAccrualLine

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :leave_type_id, :number_of_units, :auto_calculate

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.LeaveAccrualLine{
        b.LeaveTypeID self.leave_type_id if self.leave_type_id
        b.NumberOfUnits self.number_of_units if self.number_of_units
        b.AutoCalculate self.auto_calculate if self.auto_calculate
      }
    end

    def self.from_xml(leave_accrual_line_element, gateway = nil)
      leave_accrual_line = LeaveAccrualLine.new
      leave_accrual_line_element.children.each do |element|
        case (element.name)
          when "LeaveTypeID"     then leave_accrual_line.leave_type_id = element.text
          when "NumberOfUnits"   then leave_accrual_line.number_of_units = element.text
          when "AutoCalculate"   then leave_accrual_line.auto_calculate = element.text
        end
      end
      leave_accrual_line
    end

    def ==(other)
     [ :leave_type_id, :number_of_units, :auto_calculate ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
