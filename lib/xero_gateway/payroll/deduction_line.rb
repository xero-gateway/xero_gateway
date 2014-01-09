module XeroGateway::Payroll
  class DeductionLine

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :deduction_type_id, :calculation_type, :percentage, :number_of_units, :amount

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.DeductionLine{
        b.DeductionTypeID self.deduction_type_id if self.deduction_type_id
        b.CalculationType self.calculation_type if self.calculation_type
        b.Percentage self.percentage if self.percentage
        b.NumberOfUnits self.number_of_units if self.number_of_units
        b.Amount self.amount if self.amount
      }
    end

    def self.from_xml(deduction_line_element, gateway = nil)
      deduction_line = DeductionLine.new
      deduction_line.gateway = gateway
      deduction_line_element.children.each do |element|
        case (element.name)
          when "DeductionTypeID" then deduction_line.deduction_type_id = element.text
          when "CalculationType" then deduction_line.calculation_type = element.text
          when "Percentage"      then deduction_line.percentage = element.text
          when "NumberOfUnits"   then deduction_line.number_of_units = element.text
          when "Amount"          then deduction_line.amount = element.text.to_f
        end
      end
      deduction_line
    end

    def ==(other)
     [ :deduction_type_id, :calculation_type, :percentage, :number_of_units, :amount ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
