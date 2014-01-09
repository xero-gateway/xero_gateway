module XeroGateway::Payroll
  class TaxLine

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :tax_type_name, :description, :amount, :liability_account, :payslip_tax_line_id

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.TaxLine{
        b.TaxTypeName self.tax_type_name if self.tax_type_name
        b.Description self.description if self.description
        b.Amount self.amount if self.amount
        b.LiabilityAccount self.liability_account if self.liability_account
        b.PayslipTaxLineID self.payslip_tax_line_id if self.payslip_tax_line_id
      }
    end

    def self.from_xml(tax_line_element, gateway = nil)
      tax_line = TaxLine.new
      tax_line.gateway = gateway
      tax_line_element.children.each do |element|
        case (element.name)
          when "TaxTypeName" then tax_line.tax_type_name = element.text
          when "Description" then tax_line.description = element.text
          when "Amount" then tax_line.amount = element.text
          when "LiabilityAccount" then tax_line.liability_account = element.text
          when "PayslipTaxLineID" then tax_line.payslip_tax_line_id = element.text
        end
      end
      tax_line
    end

    def ==(other)
     [ :tax_type_name, :description, :amount, :liability_account, :payslip_tax_line_id ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
