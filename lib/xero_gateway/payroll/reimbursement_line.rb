module XeroGateway::Payroll
  class ReimbursementLine

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :reimbursement_type_id, :description, :expense_account, :amount

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def attributes
      { reimbursement_type_id: reimbursement_type_id,
        description: description,
        expense_account: expense_account,
        amount: amount }
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.ReimbursementLine{
        b.ReimbursementTypeID self.reimbursement_type_id if self.reimbursement_type_id
        b.Description self.description if self.description
        b.ExpenseAccount self.expense_account if self.expense_account
        b.Amount self.amount if self.amount
      }
    end

    def self.from_xml(reimbursement_line_element, gateway = nil)
      reimbursement_line = ReimbursementLine.new
      reimbursement_line.gateway = gateway
      reimbursement_line_element.children.each do |element|
        case (element.name)
          when "ReimbursementTypeID" then reimbursement_line.reimbursement_type_id = element.text
          when "Description" then reimbursement_line.description = element.text
          when "ExpenseAccount" then reimbursement_line.expense_account = element.text
          when "Amount" then reimbursement_line.amount = element.text
        end
      end
      reimbursement_line
    end

    def ==(other)
     [ :reimbursement_type_id, :description, :expense_account, :amount ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
