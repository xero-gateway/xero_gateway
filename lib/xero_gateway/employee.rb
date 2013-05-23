module XeroGateway
  class Employee
    include Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    EMPLOYEE_STATUS = {
      'ACTIVE' =>     'Active',
      'DELETED' =>    'Deleted'
    } unless defined?(EMPLOYEE_STATUS)

    # Xero::Gateway associated with this employee.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :employee_id, :status, :first_name, :last_name, :email, :external_link, :date_of_birth, :gender

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end


    # Validate the Employee record according to what will be valid by the gateway.
    #
    # Usage:
    #  employee.valid?     # Returns true/false
    #
    #  Additionally sets employee.errors array to an array of field/error.
    def valid?
      @errors = []

      if !employee_id.nil? && employee_id !~ GUID_REGEX
        @errors << ['employee_id', 'must be blank or a valid Xero GUID']
      end

      if status && !EMPLOYEE_STATUS[status]
        @errors << ['status', "must be one of #{EMPLOYEE_STATUS.keys.join('/')}"]
      end
      @errors.size == 0
    end

    # General purpose create/save method.
    def save
      if employee_id.nil?
        create
      else
        update
      end
    end

    # Creates this employee record (using gateway.create_employee) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    # def create
    #   raise NoGatewayError unless gateway
    #   gateway.create_employee(self)
    # end

    def create
      raise NoGatewayError unless gateway
      gateway.create_employee(self)
    end

    # Creates this employee record (using gateway.update_employee) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    # def update
    #   raise NoGatewayError unless gateway
    #   gateway.update_employee(self)
    # end

    def to_xml(b = Builder::XmlMarkup.new)
      b.Employee {
        b.EmployeeID self.employee_id if self.employee_id
        b.FirstName self.first_name if self.first_name
        b.LastName self.last_name if self.last_name
        b.EmailAddress self.email if self.email
        b.ExternalLink self.external_link if self.external_link
      }
    end

    # Take a Employee element and convert it into an Employee object
    def self.from_xml(employee_element, gateway = nil)
      employee = Employee.new(:gateway => gateway)
      employee_element.children.each do |element|
        case(element.name)
          when "EmployeeID" then employee.employee_id = element.text
          when "Status" then employee.status = element.text
          when "FirstName" then employee.first_name = element.text
          when "LastName" then employee.last_name = element.text
          when "ExternalLink" then employee.external_link = element.text
          when "EmailAddress" then contact.email = element.text
        end
      end
      employee
    end

    # Take some Employees element to send out to User - PVT: 49575441
    def self.from_xml_to_user(employee_element, gateway = nil)
      employee = Employee.new(:gateway => gateway)
      employee_element.children.each do |element|
        case(element.name)
          when "DateOfBirth" then employee.date_of_birth = element.text
          when "Gender"      then employee.gender        = element.text
        end
      end
      employee
    end

    def ==(other)
      [ :employee_id, :status, :first_name, :last_name, :email ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
