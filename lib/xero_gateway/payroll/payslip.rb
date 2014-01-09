module XeroGateway::Payroll
  class NoGatewayError < StandardError; end
  class TimesheetEarningsLine < EarningsRate; end
  class LeaveEarningsLine < EarningsRate; end

  class Payslip
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :employee_id, :payslip_id, :earnings_lines, :timesheet_earnings_lines, :deduction_lines,
                  :leave_accrual_lines, :reimbursement_lines, :superannuation_lines, :tax_lines, :first_name,
                  :last_name, :employee_group, :last_edited, :wages, :deductions, :net_pay, :tax, :super,
                  :reimbursements, :leave_earnings_lines

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @earnings_lines ||= []
      @timesheet_earnings_lines ||= []
      @deduction_lines ||= []
      @leave_accrual_lines ||= []
      @reimbursement_lines ||= []
      @superannuation_lines ||= []
      @tax_lines ||= []
      @leave_earnings_lines ||= []
    end

    def total_help_component_tax
      help_component_tax = tax_lines.select {|obj| obj.tax_type_name == "HELP Component" }
      help_component_tax.sum {|a| a.amount.to_f }
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.Payslip{
        b.EmployeeID self.employee_id if self.employee_id
        b.PayslipID self.payslip_id if self.payslip_id
        b.EarningsLines{
          self.earnings_lines.each do |earnings_line|
            earnings_line.to_xml(b)
          end
        } unless self.earnings_lines.blank?
        b.TimesheetEarningsLines{
          self.timesheet_earnings_lines.each do |timesheet_earnings_line|
            timesheet_earnings_line.to_xml(b)
          end
        } unless self.timesheet_earnings_lines.blank?
        b.DeductionLines{
          self.deduction_lines.each do |deduction_line|
            deduction_line.to_xml(b)
          end
        } unless self.deduction_lines.blank?
        b.LeaveAccrualLines{
          self.leave_accrual_lines.each do |leave_accrual_line|
            leave_accrual_line.to_xml(b)
          end
        } unless self.leave_accrual_lines.blank?
        b.ReimbursementLines{
          self.reimbursement_lines.each do |reimbursement_line|
            reimbursement_line.to_xml(b)
          end
        } unless reimbursement_lines.blank?
        b.SuperannuationLines{
          self.superannuation_lines.each do |superannuation_line|
            superannuation_line.to_xml(b)
          end
        } unless self.superannuation_lines.blank?
        b.TaxLines{
          self.tax_lines.each do |tax_line|
            tax_line.to_xml(b)
          end
        } unless self.tax_lines.blank?
        b.FirstName self.first_name if self.first_name
        b.LastName self.last_name if self.last_name
        b.EmployeeGroup self.employee_group if self.employee_group
        b.LastEdited self.last_edited if self.last_edited
        b.Wages self.wages if self.wages
        b.Deductions self.deductions if self.deductions
        b.NetPay self.net_pay if self.net_pay
        b.Tax self.tax if self.tax
        b.Super self.super if self.super
        b.Reimbursements if self.reimbursements if self.reimbursements
        b.LeaveEarningsLines{
          self.leave_earnings_lines.each do |leave_earnings_line|
            leave_earnings_line.to_xml(b)
          end
        } unless self.leave_earnings_lines.blank?
      }
    end

    def self.from_xml(payslip_element, gateway = nil)
      payslip = Payslip.new
      payslip.gateway = gateway
      payslip_element.children.each do |element|
        case (element.name)
          when "EmployeeID" then payslip.employee_id = element.text
          when "PayslipID" then payslip.payslip_id = element.text
          when "EarningsLines" then element.children.each{|child| payslip.earnings_lines << EarningsLine.from_xml(child, gateway)}
          when "TimesheetEarningsLines" then element.children.each{|child| payslip.timesheet_earnings_lines << TimesheetEarningsLine.from_xml(child, gateway)}
          when "DeductionLines" then element.children.each{|child| payslip.deduction_lines << DeductionLine.from_xml(child, gateway)}
          when "LeaveAccrualLines" then element.children.each{|child| payslip.leave_accrual_lines << LeaveAccrualLine.from_xml(child, gateway)}
          when "ReimbursementLines" then element.children.each{|child| payslip.reimbursement_lines << ReimbursementLine.from_xml(child, gateway)}
          when "SuperannuationLines" then element.children.each{|child| payslip.superannuation_lines << SuperannuationLine.from_xml(child, gateway)}
          when "TaxLines" then element.children.each{|child| payslip.tax_lines << TaxLine.from_xml(child, gateway)}
          when "FirstName" then payslip.first_name = element.text
          when "LastName" then payslip.last_name = element.text
          when "EmployeeGroup" then payslip.employee_group = element.text
          when "LastEdited" then payslip.last_edited = element.text
          when "Wages" then payslip.wages = element.text
          when "Deductions" then payslip.deductions = element.text
          when "NetPay" then payslip.net_pay = element.text
          when "Tax" then payslip.tax = element.text
          when "Super" then payslip.super = element.text
          when "Reimbursements" then payslip.reimbursements = element.text
          when "LeaveEarningsLines" then element.children.each{|child| payslip.leave_earnings_lines << LeaveEarningsLine.from_xml(child, gateway) }
        end
      end
      payslip
    end

    def ==(other)
     [ :employee_id, :payslip_id, :earnings_lines, :timesheet_earnings_lines, :deduction_lines,
        :leave_accrual_lines, :reimbursement_lines, :superannuation_lines, :tax_lines, :first_name,
        :last_name, :employee_group, :last_edited, :wages, :deductions, :net_pay, :tax, :super,
        :reimbursements, :leave_earnings_lines ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
