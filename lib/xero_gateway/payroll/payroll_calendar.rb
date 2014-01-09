module XeroGateway::Payroll
  class NoGatewayError < StandardError; end

  class PayrollCalendar
    include XeroGateway::Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    CALENDAR_TYPES =["WEEKLY", "FORTNIGHTLY", "FOURWEEKLY", "MONTHLY", "TWICEMONTHLY", "QUARTERLY"]

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :name, :calendar_type, :start_date, :payment_date, :payroll_calendar_id

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.PayrollCalendar{
        b.PayrollCalendarID self.payroll_calendar_id if self.payroll_calendar_id
        b.Name self.name if self.name
        b.CalendarType self.calendar_type if self.calendar_type
        b.StartDate format_date_time(self.start_date) if self.start_date
        b.PaymentDate format_date_time(self.payment_date) if self.payment_date
      }
    end

    def self.from_xml(payroll_calendar_element, gateway = nil)
      payroll_calendar = PayrollCalendar.new
      payroll_calendar.gateway = gateway
      payroll_calendar_element.children.each do |element|
        case (element.name)
          when "PayrollCalendarID" then payroll_calendar.payroll_calendar_id = element.text
          when "Name" then payroll_calendar.name = element.text
          when "CalendarType" then payroll_calendar.calendar_type = element.text
          when "StartDate" then payroll_calendar.start_date = parse_date(element.text)
          when "PaymentDate" then payroll_calendar.payment_date = parse_date(element.text)
        end
      end
      payroll_calendar
    end

    def ==(other)
     [ :name, :calendar_type, :start_date, :payment_date, :payroll_calendar_id ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
