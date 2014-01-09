module XeroGateway::Payroll
  class BankAccount

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :statement_text, :account_name, :bsb, :account_number, :remainder, :percentage, :amount

     def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.BankAccount {
        b.StatementText self.statement_text if self.statement_text
        b.AccountName self.account_name if self.account_name
        b.BSB self.bsb if self.bsb
        b.AccountNumber self.account_number if self.account_number
        b.Remainder self.remainder if !self.remainder.nil?
        b.Percentage self.percentage if self.percentage
        b.Amount self.amount if self.amount
      }
    end

    def self.from_xml(bank_account_element, gateway = nil)
      bank_account = BankAccount.new
      bank_account.gateway = gateway
      bank_account_element.children.each do |element|
        case(element.name)
          when "StatementText" then bank_account.statement_text = element.text
          when "AccountName" then  bank_account.account_name = element.text
          when "BSB" then bank_account.bsb = element.text
          when "AccountNumber" then bank_account.account_number = element.text
          when "Remainder" then bank_account.remainder = element.text
          when "Percentage" then bank_account.percentage = element.text
          when "Amount" then bank_account.amount = element.text
        end
      end
      bank_account
    end

    def ==(other)
      [ :statement_text, :account_name, :bsb, :account_number, :remainder, :percentage, :amount ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
