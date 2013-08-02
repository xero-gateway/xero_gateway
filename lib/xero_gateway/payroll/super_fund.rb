module XeroGateway::Payroll
  class SuperFund

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    # Xero::Gateway associated with this super_fund.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :super_fund_id, :type, :name, :abn, :bsb, :account_number, :account_name, :employer_number, :employee_number

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.SuperFund {
      	b.SuperFundID self.super_fund_id if self.super_fund_id
        b.Type self.type if self.type
        b.Name self.name if self.name
        b.ABN self.abn if self.abn
        b.BSB self.bsb if self.bsb
        b.AccountNumber self.account_number if self.account_number
        b.AccountName self.account_name if self.account_name
        b.EmployerNumber self.employer_number if self.employer_number
        b.EmployeeNumber self.employee_number if self.employee_number
      }
    end

    def self.from_xml(super_fund_element, gateway = nil)
      super_fund = SuperFund.new
      super_fund_element.children.each do |element|
        case(element.name)
        	when "SuperFundID" then super_fund.super_fund_id = element.text
          when "Name" then super_fund.name = element.text
          when "ABN" then super_fund.abn = element.text
          when "Type" then super_fund.type = element.text
          when "BSB" then super_fund.bsb = element.text
          when "AccountNumber" then super_fund.account_number = element.text
          when "AccountName" then super_fund.account_name = element.text
          when "EmployerNumber" then super_fund.employer_number = element.text
          when "EmployeeNumber" then super_fund.employee_number = element.text
        end
      end
      super_fund
    end

    def ==(other)
      [ :super_fund_id, :type, :name, :abn, :bsb, :account_number, :account_name, :employer_number, :employee_number ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
