module XeroGateway::Payroll
  class NoGatewayError < StandardError; end

  class Employee
    include XeroGateway::Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    EMPLOYEE_STATUS = {
      'ACTIVE' =>     'Active',
      'DELETED' =>    'Deleted'
    } unless defined?(EMPLOYEE_STATUS)

    # Xero::Gateway associated with this employee.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :employee_id, :first_name, :date_of_birth, :email, :gender, :last_name,
                  :middle_name, :title, :start_date, :job_title, :mobile, :status,
                  :phone, :termination_date, :home_address, :bank_accounts, :super_memberships, :pay_template,
                  :tax_declaration, :payroll_calendar, :payroll_calendar_id, :classification, :ordinary_earnings_rate_id

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @bank_accounts ||= []
      @super_memberships ||= []
    end

    def build_home_address(params = {})
      self.home_address = gateway ? gateway.build_payroll_employee_address(params) : HomeAddress.new(params)
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
    # TO DO : others fields validation
    def valid?
      @errors = []

      if employee_id && employee_id !~ GUID_REGEX
        @errors << ['employee_id', 'cannot be blank and must be a valid Xero GUID']
      end

      if status && !EMPLOYEE_STATUS[status]
        @errors << ['status', "must be one of #{EMPLOYEE_STATUS.keys.join('/')}"]
      end

      if job_title && job_title.length > 50
        @errors << ['job_title', "is too long (maximum is 50 characters)"]
      end

      if mobile && mobile.length > 50
        @errors << ['mobile', "is too long (maximum is 50 characters)"]
      end

      if phone && phone.length > 50
        @errors << ['phone', "is too long (maximum is 50 characters)"]
      end

      if date_of_birth.blank?
        @errors << ['Date of Birth', "cannot be blank"]
      elsif date_of_birth >= Date.today
        @errors << ['Date of Birth', "must be in the past"]
      end

      @errors += home_address.errors unless home_address.valid?

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
        b.DateOfBirth self.class.format_date(self.date_of_birth) if self.date_of_birth
        b.Email self.email if self.email
        b.Gender self.gender if self.gender
        b.LastName self.last_name if self.last_name
        b.MiddleNames self.middle_name if self.middle_name
        self.tax_declaration.to_xml(b) if self.tax_declaration
        b.Title self.title if self.title
        b.StartDate self.class.format_date(self.start_date || Date.today) if self.start_date
        b.JobTitle self.job_title if self.job_title
        b.Classification self.classification if self.classification
        b.OrdinaryEarningsRateID self.ordinary_earnings_rate_id if self.ordinary_earnings_rate_id
        b.Mobile self.mobile if self.mobile
        b.Phone self.phone if self.phone
        b.TerminationDate self.termination_date if self.termination_date
        b.PayrollCalendarID self.payroll_calendar_id if self.payroll_calendar_id
        self.pay_template.to_xml(b) if self.pay_template
        b.BankAccounts{
          self.bank_accounts.each do |bank_account|
            bank_account.to_xml(b) if bank_account.valid?
          end
        }
        b.SuperMemberships{
          self.super_memberships.each do |super_membership|
            super_membership.to_xml(b)
          end
        }unless self.super_memberships.blank?
        home_address.to_xml(b) if self.home_address.valid?
      }
    end

    def self.from_xml(employee_element, gateway = nil)
      employee = Employee.new
      employee.gateway = gateway
      employee_element.children.each do |element|
        case(element.name)
          when "EmployeeID" then employee.employee_id = element.text
          when "DateOfBirth" then employee.date_of_birth = parse_date_time(element.text)
          when "Email" then employee.email = element.text
          when "FirstName" then employee.first_name = element.text
          when "Gender" then employee.gender = element.text
          when "LastName" then employee.last_name = element.text
          when "MiddleNames" then employee.middle_name = element.text
          when "Title" then employee.title = element.text
          when "StartDate" then employee.start_date =  parse_date_time(element.text)
          when "JobTitle" then employee.job_title = element.text
          when "Classification" then employee.classification = element.text
          when "OrdinaryEarningsRateID" then employee.ordinary_earnings_rate_id = element.text
          when "Mobile" then employee.mobile = element.text
          when "Phone" then employee.phone = element.text
          when "TerminationDate" then employee.termination_date = parse_date_time(element.text)
          when "HomeAddress" then employee.home_address = HomeAddress.from_xml(element)
          when "PayTemplate" then employee.pay_template = PayTemplate.from_xml(element)
          when "BankAccounts" then element.children.each {|child| employee.bank_accounts << BankAccount.from_xml(child, gateway) }
          when "SuperMemberships" then element.children.each {|child| employee.super_memberships << SuperMembership.from_xml(child, gateway) }
          when "TaxDeclaration" then employee.tax_declaration = TaxDeclaration.from_xml(element)
          when "PayrollCalendarID" then employee.payroll_calendar = gateway.get_payroll_calendar_by_id(element.text).response_item
          when "Status" then employee.status = element.text
        end
      end
      employee
    end

    def ==(other)
      [ :employee_id, :status, :first_name, :date_of_birth, :email, :gender, :last_name, :middle_name,
      :title, :start_date, :job_title, :mobile, :phone, :termination_date, :home_address, :bank_accounts,
      :tax_declaration ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end


    def full_name
      "#{first_name} #{middle_name} #{last_name}"
    end
  end
end
