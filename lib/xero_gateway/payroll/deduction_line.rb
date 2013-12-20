module XeroGateway::Payroll
  class DeductionLine

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :deduction_type_id, :calculation_type, :percentage, :number_of_units

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
        b.CalculationTyoe self.calculation_type if self.calculation_type
        b.Percentage self.percentage if self.percentage
        b.NumberOfUnits self.number_of_units if self.number_of_units
      }
    end

    def self.from_xml(deduction_line_element, gateway = nil)
      @gateway = gateway
      deduction_line = DeductionLine.new
      deduction_line_element.children.each do |element|
        case (element.name)
          when "DeductionTypeID" then deduction_line.deduction_type_id = element.text
          when "CalculationTyoe" then deduction_line.calculation_type = element.text
          when "Percentage"      then deduction_line.percentage = element.text
          when "NumberOfUnits"   then deduction_line.number_of_units = element.text
        end
      end
      deduction_line
    end

    def ==(other)
     [ :deduction_type_id, :calculation_type, :percentage, :number_of_units ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
