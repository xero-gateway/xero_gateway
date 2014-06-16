require 'active_model'
module XeroGateway::Payroll
  class NoGatewayError < StandardError; end

  class LeaveApplication
    include XeroGateway::Dates
    include ActiveModel::Validations

    # Xero::Gateway associated with this leave_period.
    attr_accessor :gateway

    attr_accessor :employee_id, :leave_type_id, :title, :start_date, :end_date, :description, :leave_periods, :leave_application_id

    validates_presence_of :employee_id, :leave_type_id, :title, :start_date, :end_date
    validates_length_of :description, maximum: 200

    def initialize(params = {})

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @leave_periods ||= []
    end

    # General purpose create/save method.
    def save
      if leave_application_id.nil?
        create
      else
        update
      end
    end

    # Creates this leave_application record (using gateway.create_payroll_leave_application) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway

      gateway.create_leave_application(self)
    end

    # Creates this leave_application record (using gateway.update_payroll_leave_application) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def update
      raise NoGatewayError unless gateway
      gateway.update_leave_application(self)
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.LeaveApplication {
      	b.EmployeeID self.employee_id if self.employee_id
      	b.LeaveTypeID self.leave_type_id if self.leave_type_id
      	b.Title self.title if self.title
      	b.StartDate self.class.format_date(self.start_date || Date.today) if self.start_date
      	b.EndDate self.class.format_date(self.end_date || Date.today) if self.end_date
        b.Description self.description if self.description
        b.LeavePeriods{
          self.leave_periods.each do |leave_period|
            leave_period.to_xml(b)
          end
        }unless self.leave_periods.blank?
        b.LeaveApplicationID self.leave_application_id if self.leave_application_id
      }
    end

    def self.from_xml(leave_application_element, gateway = nil)
      leave_application = LeaveApplication.new
      leave_application.gateway = gateway
      leave_application_element.children.each do |element|
        case(element.name)
          when "EmployeeID"   then leave_application.employee_id   = element.text
          when "LeaveTypeID"  then leave_application.leave_type_id = element.text
          when "Title"        then leave_application.title         = element.text
          when "StartDate"    then leave_application.start_date    = parse_date(element.text)
          when "EndDate"      then leave_application.end_date      = parse_date(element.text)
          when "Description"  then leave_application.description   = element.text
          when "LeavePeriods" then element.children.each {|child| leave_application.leave_periods << LeavePeriod.from_xml(child, gateway) }
          when "LeaveApplicationID" then leave_application.leave_application_id = element.text
        end
      end
      leave_application
    end

    def ==(other)
      [ :employee_id, :leave_type_id, :title, :start_date, :end_date, :description, :leave_periods, :leave_application_id ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
