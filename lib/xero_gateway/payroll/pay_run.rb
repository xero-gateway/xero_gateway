module XeroGateway::Payroll
  class NoGatewayError < StandardError; end

  class PayRun
    include XeroGateway::Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    PAY_RUN_STATUS = ["DRAFT", "POSTED"] unless defined?(PAYRUNSTATUS)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :pay_run_period_end_date, :pay_run_status, :pay_run_id, :payroll_calendar_id, :payslip_message, :payslips, :pay_run_period_start_date, :payment_date, :wages, :deductions, :tax, :super, :reimbursement, :net_pay

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @payslips ||= []
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.PayRun{
        b.PayRunPeriodEndDate format_date_time(self.pay_run_period_end_date) if self.pay_run_period_end_date
        b.PayRunStatus self.pay_run_status if self.pay_run_status
        b.PayRunID self.pay_run_id if self.pay_run_id
        b.PayrollCalendarID self.payroll_calendar_id if self.payroll_calendar_id
        b.PayslipMessage self.payslip_message if self.payslip_message
        b.Payslips{
          self.payslips.each do |payslip|
            payslip.to_xml(b)
          end
        } unless self.payslips.blank?
        b.PayRunPeriodStartDate format_date_time(self.pay_run_period_start_date) if self.pay_run_period_start_date
        b.PaymentDate format_date_time(self.payment_date) if self.payment_date
        b.Wages self.wages if self.wages
        b.Deductions self.deductions if self.deductions
        b.Tax self.tax if self.tax
        b.Super self.super if self.super
        b.Reimbursement self.reimbursement	if self.reimbursement
        b.NetPay self.net_pay if self.net_pay
      }
    end

    def self.from_xml(pay_run_element, gateway = nil)
      @gateway = gateway
      pay_run = PayRun.new
      pay_run_element.children.each do |element|
        case (element.name)
          when "PayRunPeriodEndDate" then pay_run.pay_run_period_end_date = parse_date(element.text)
          when "PayRunStatus" then pay_run.pay_run_status = element.text
          when "PayRunID" then pay_run.pay_run_id = element.text
          when "PayrollCalendarID" then pay_run.payroll_calendar_id = element.text
          when "PayslipMessage" then pay_run.payslip_message = element.text
          when "Payslips" then element.children.each{|child| pay_run.payslips << Payslip.from_xml(child, gateway)}
          when "PayRunPeriodStartDate" then pay_run.pay_run_period_start_date = parse_date(element.text)
          when "PaymentDate" then pay_run.payment_date = parse_date(element.text)
          when "Wages" then pay_run.wages = element.text
          when "Deductions" then pay_run.deductions = element.text
          when "Tax" then pay_run.tax = element.text
          when "Super" then pay_run.super = element.text
          when "Reimbursement" then pay_run.reimbursement = element.text
          when "NetPay" then pay_run.net_pay = element.text
        end
      end
      pay_run
    end

    def ==(other)
     [ :pay_run_period_end_date, :pay_run_status, :pay_run_id, :payroll_calendar_id, :payslip_message, :payslips, :pay_run_period_start_date, :payment_date, :wages, :deductions, :tax, :super, :reimbursement, :net_pay ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

    def draft?
      pay_run_status == 'DRAFT'
    end

    def posted?
      pay_run_status == 'POSTED'
    end
  end
end
