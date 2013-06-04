module XeroGateway::Payroll
  class Employee
    # include Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    EMPLOYEE_STATUS = {
      'ACTIVE' =>     'Active',
      'DELETED' =>    'Deleted'
    } unless defined?(EMPLOYEE_STATUS)

    # Xero::Gateway associated with this employee.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :employee_id, :first_name, :date_of_birth, :email, :first_name, :gender, :last_name,
                  :middle_name, :tax_file_number, :title,
                  # Adding HomeAddress fields/elements
                  :home_address

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      # @home_address ||= {}
    end

    def build_home_address(params = {})
      self.home_address = gateway ? gateway.build_payroll_employee_address(params) : Address.new(params)
    end
    
    def home_address
      @home_address ||= build_home_address
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

    # Creates this employee record (using gateway.create_payroll_employee) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway
      gateway.create_payroll_employee(self)
    end

    # Creates this employee record (using gateway.update_payroll_employee) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def update
      raise NoGatewayError unless gateway
      gateway.update_payroll_employee(self)
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.Employee {
      	b.EmployeeID self.employee_id if self.employee_id
        b.FirstName self.first_name if self.first_name
        b.DateOfBirth self.date_of_birth if self.date_of_birth
        b.Email self.email if self.email
        b.FirstName self.first_name if self.first_name
        b.Gender self.gender if self.gender
        b.LastName self.last_name if self.last_name
        b.MiddleNames self.middle_name if self.middle_name
        b.TaxFileNumber self.tax_file_number if self.tax_file_number
        b.Title self.title if self.title
        home_address.to_xml(b)
      }
    end
    
    # Should add other fields based on Pivotal: 49575441
    def self.from_xml(employee_element, gateway = nil)
      employee = Employee.new
      employee_element.children.each do |element|
        case(element.name)
        	when "EmployeeID" then employee.employee_id = element.text
          when "DateOfBirth" then employee.date_of_birth = element.text
          when "Email" then employee.email = element.text
          when "FirstName" then employee.first_name = element.text
          when "Gender" then employee.gender = element.text
          when "LastName" then employee.last_name = element.text
          when "MiddleNames" then employee.middle_name = element.text
          when "TaxFileNumber" then employee.tax_file_number = element.text
          when "Title" then employee.title = element.text
          when "HomeAddress" then employee.home_address = Address.from_xml(element)
        end
      end
      employee
    end

    def ==(other)
      [ :employee_id, :first_name, :date_of_birth, :email, :first_name, :gender, :last_name, :middle_name, :tax_file_number, :title, :home_address ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
