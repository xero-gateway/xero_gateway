module XeroGateway::Payroll
  class LeavePeriod
    include XeroGateway::Dates

    LEAVE_PERIOD_STATUS = [
      "SCHEDULED", "PROCESSED"
    ]unless defined?(LEAVE_PERIOD_STATUS)

    # Xero::Gateway associated with this leave_period.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :number_of_units, :pay_period_end_date, :pay_period_start_date, :leave_period_status

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def valid?
      @errors = []

      if leave_period_status && !LEAVE_PERIOD_STATUS.include?(leave_period_status)
        errors << ["leave_period_status", "is invalid!"]
      end

      errors.size == 0
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.LeavePeriod {
      	b.NumberOfUnits self.number_of_units if self.number_of_units
      	b.PayPeriodEndDate self.class.format_date(self.pay_period_end_date || Date.today) if self.pay_period_end_date
      	b.PayPeriodStartDate self.class.format_date(self.pay_period_start_date || Date.today) if self.pay_period_start_date
      	b.LeavePeriodStatus self.leave_period_status if self.leave_period_status
      }
    end

    def self.from_xml(leave_period_element, gateway = nil)
      @gateway = gateway
      leave_period = LeavePeriod.new
      leave_period_element.children.each do |element|
        case(element.name)
          when "NumberOfUnits" then leave_period.number_of_units = element.text
          when "PayPeriodEndDate" then leave_period.pay_period_end_date = parse_date(element.text)
          when "PayPeriodStartDate" then leave_period.pay_period_start_date = parse_date(element.text)
          when "LeavePeriodStatus" then leave_period.leave_period_status = element.text
        end
      end
      leave_period
    end

    def ==(other)
      [ :number_of_units, :pay_period_end_date, :pay_period_start_date, :leave_period_status].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
