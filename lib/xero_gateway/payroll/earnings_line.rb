module XeroGateway::Payroll
  class EarningsLine
    
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :number_of_units_per_week, :annual_salary, :rate_per_unit, :normal_number_of_units
    
     def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.EarningsLine {
      	b.NumberOfUnitsPerWeek self.number_of_units_per_week if self.number_of_units_per_week
        b.AnnualSalary self.annual_salary if self.annual_salary
        b.RatePerUnit self.rate_per_unit if self.rate_per_unit
        b.NormalNumberOfUnits self.normal_number_of_units if self.normal_number_of_units
      }
    end
    
    def self.from_xml(earnings_line_element, gateway = nil)
      earnings_line = EarningsLine.new
      earnings_line_element.children.each do |element|
        case(element.name)
          when "NumberOfUnitsPerWeek" then earnings_line.number_of_units_per_week = element.text
          when "AnnualSalary" then  earnings_line.annual_salary = element.text
          when "RatePerUnit" then earnings_line.rate_per_unit = element.text 
          when "NormalNumberOfUnits" then earnings_line.normal_number_of_units = element.text
        end
      end
      earnings_line
    end

    def ==(other)
      [ :number_of_units_per_week, :annual_salary, :rate_per_unit, :normal_number_of_units ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
