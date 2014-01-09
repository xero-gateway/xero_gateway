module XeroGateway::Payroll
  class DeductionType

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :name, :account_code, :reduces_tax, :reduces_super, :deduction_type_id

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def valid?
      @errors = []

      if !deduction_type_id.blank? && deduction_type_id !~ GUID_REGEX
        @errors << ['employee_id', 'invalid ID']
      end

      if name.blank?
        @errors << ['name', "can't be blank"]
      end

      if account_code.blank?
        @errors << ['account_code', "can't be blank"]
      end

      if reduces_tax.blanl?
        @errors << ['reduces_tax', "can't be blank"]
      end

      if reduces_super.blank?
        @errors << ['reduces_super', "can't be blank"]
      end

      @errors.size == 0
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.DeductionType{
        b.Name self.name if self.name
        b.AccountCode self.account_code if self.account_code
        b.ReducesTax self.reduces_tax if self.reduces_tax
        b.ReducesSuper self.reduces_super if self.reduces_super
        b.DeductionTypeID self.deduction_type_id if self.deduction_type_id
      }
    end

    def self.from_xml(deduction_type_element, gateway = nil)
      deduction_type = DeductionType.new
      deduction_type.gateway = gateway
      deduction_type_element.children.each do |element|
        case (element.name)
          when "Name" then deduction_type.name = element.text
          when "AccountCode" then deduction_type.account_code = element.text
          when "TypeOfUnits" then deduction_type.type_of_units = element.text
          when "ReducesTax" then deduction_type.reduces_tax = element.text
          when "ReducesSuper" then deduction_type.reduces_super = element.text
          when "DeductionTypeID" then deduction_type.deduction_type_id = element.text
        end
      end
      deduction_type
    end

    def ==(other)
      [:name, :account_code, :reduces_tax, :reduces_super, :deduction_type_id].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
