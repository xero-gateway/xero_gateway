module XeroGateway::Payroll
  class SuperannuationLine

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :super_membership_id, :contribution_type, :calculation_type, :minimum_monthly_earnings, :expense_account_code, :liability_account_code, :payment_date_for_this_period, :percentage, :amount

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.SuperannuationLine{
        b.SuperMembershipID self.super_membership_id if self.super_membership_id
        b.ContributionType self.contribution_type if self.contribution_type
        b.CalculationTyoe self.calculation_type if self.calculation_type
        b.MinimumMonthlyEarnings self.minimum_monthly_earnings if self.minimum_monthly_earnings
        b.ExpenseAccountCode self.expense_account_code if self.expense_account_code
        b.LiabilityAccountCode self.liability_account_code if self.liability_account_code
        b.PaymentDateForThisPeriod self.payment_date_for_this_period if self.payment_date_for_this_period
        b.Percentage self.percentage if self.percentage
        b.Amount self.amount if self.amount
      }
    end

    def self.from_xml(superannuation_line_element, gateway = nil)
      superannuation_line = ReimbursementLine.new
      superannuation_line_element.children.each do |element|
        case (element.name)
          when "SuperMembershipID" then superannuation_line.super_membership_id = element.text
          when "ContributionType" then superannuation_line.contribution_type = element.text
          when "CalculationTyoe" then superannuation_line.calculation_type = element.text
          when "MinimumMonthlyEarnings" then superannuation_line.minimum_monthly_earnings = element.text
          when "ExpenseAccountCode" then superannuation_line.expense_account_code = element.text
          when "LiabilityAccountCode" then superannuation_line.liability_account_code = element.text
          when "PaymentDateForThisPeriod" then superannuation_line.payment_date_for_this_period = element.text
          when "Percentage" then superannuation_line.percentage = element.text
          when "Amount" then superannuation_line.amount = element.text
        end
      end
      superannuation_line
    end

    def ==(other)
     [ :super_membership_id, :contribution_type, :calculation_type, :minimum_monthly_earnings, :expense_account_code, :liability_account_code, :payment_date_for_this_period, :percentage, :amount ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
