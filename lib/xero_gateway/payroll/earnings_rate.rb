module XeroGateway::Payroll
  class EarningsRate

    EARNINGS_TYPES = [
      "FIXED", "ORDINARYTIMEEARNINGS", "OVERTIMEEARNINGS", "ALLOWANCE"
    ]unless defined?(EARNINGS_TYPES)

    RATE_TYPES = [
      "FIXED", "MULTIPLE", "RATEPERUNIT"
    ]unless defined?(RATE_TYPES)

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :name, :account_code, :type_of_units, :is_exempt_from_tax, :is_exempt_from_super, :earnings_type, :earnings_rate_id,
    :rate_type, :rate_per_unit, :multiplier, :accrue_leave, :amount

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def valid?
      @errors = []

      if !earnings_rate_id.blank? && earnings_rate_id !~ GUID_REGEX
        @errors << ['employee_id', 'invalid ID']
      end

      if name.blank?
        @errors << ['name', "can't be blank"]
      end

      if type_of_units.blank?
        @errors << ['type_of_units', "can't be blank"]
      end

      if account_code.blank?
        @errors << ['account_code', "can't be blank"]
      end

      if is_exempt_from_tax.blanl?
        @errors << ['is_exempt_from_tax', "can't be blank"]
      end

      if is_exempt_from_super.blank?
        @errors << ['is_exempt_from_super', "can't be blank"]
      end

      if earnings_type.blank?
        @errors << ['earnings_type', "can't be blank"]
      end

      @errors.size == 0
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.EarningsRate{
        b.Name self.name if self.name
        b.AccountCode self.account_code if self.account_code
        b.TypeOfUnits self.type_of_units if self.type_of_units
        b.IsExemptFromTax self.is_exempt_from_tax if self.is_exempt_from_tax
        b.IsExemptFromSuper self.is_exempt_from_super if self.is_exempt_from_super
        b.EarningsType self.earnings_type if self.earnings_type
        b.EarningsRateID self.earnings_rate_id if self.earnings_rate_id
        b.RateType self.rate_type if self.rate_type
        b.RatePerUnit self.rate_per_unit if self.rate_per_unit
        b.Multiplier self.multiplier if self.multiplier
        b.AccrueLeave self.accrue_leave if self.accrue_leave
        b.Amount self.amount if self.amount
      }
    end

    def self.from_xml(earnings_rate_element, gateway = nil)
      earnings_rate = EarningsRate.new
      earnings_rate.gateway = gateway
      earnings_rate_element.children.each do |element|
        case (element.name)
          when "Name" then earnings_rate.name = element.text
          when "AccountCode" then earnings_rate.account_code = element.text
          when "TypeOfUnits" then earnings_rate.type_of_units = element.text
          when "IsExemptFromTax" then earnings_rate.is_exempt_from_tax = element.text
          when "IsExemptFromSuper" then earnings_rate.is_exempt_from_super = element.text
          when "EarningsType" then earnings_rate.earnings_type = element.text
          when "EarningsRateID" then earnings_rate.earnings_rate_id = element.text
          when "RateType" then earnings_rate.rate_type = element.text
          when "RatePerUnit" then earnings_rate.rate_per_unit = element.text
          when "Multiplier" then earnings_rate.multiplier = element.text
          when "AccrueLeave" then earnings_rate.accrue_leave = element.text
          when "Amount"then earnings_rate.amount = element.text
        end
      end
      earnings_rate
    end

    def ==(other)
     [ :name, :account_code, :type_of_units, :is_exempt_from_tax, :is_exempt_from_super, :earnings_type, :earnings_rate_id,
    :rate_type, :rate_per_unit, :multiplier, :accrue_leave, :amount ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
