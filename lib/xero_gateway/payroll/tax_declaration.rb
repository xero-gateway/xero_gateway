module XeroGateway::Payroll
  class TaxDeclaration
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    EMPLOYMENT_BASIS = [
      'FULLTIME',
      'PARTTIME',
      'CASUAL',
      'LABOURHIRE',
      'SUPERINCOMESTREAM'
    ] unless defined?(EMPLOYMENT_BASIS)

    # Xero::Gateway associated with this tax_declaration.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :employment_basis, :tfn_pending_or_exemption_held, :tax_file_number,
      :australian_resident_for_tax_purposes, :tax_free_threshold_claimed, :tax_offset_estimated_amount,
      :has_help_debt, :has_sfss_debt, :upward_variation_tax_withholding_amount, :eligible_to_receive_leave_loading,
      :approved_withholding_variation_percentage, :updated_date_utc, :employee_id

    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    # Validate the TaxDeclaration record according to what will be valid by the gateway.
    #
    # Usage:
    #  tax_declaration.valid?     # Returns true/false
    #
    #  Additionally sets tax_declaration.errors array to an array of field/error.
    # TO DO : others fields validation
    def valid?
      @errors = []

      if employment_basis && !EMPLOYEE_STATUS.include?(employment_basis)
        @errors << ['employment_basis', "is invalid"]
      end

      @errors.size == 0
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.TaxDeclaration{
        b.EmployeeID if self.employee_id
        b.EmploymentBasis self.employment_basis if self.employment_basis
        b.TFNPendingOrExemptionHeld self.tfn_pending_or_exemption_held if self.tfn_pending_or_exemption_held
        b.TaxFileNumber self.tax_file_number if self.tax_file_number
        b.AustralianResidentForTaxPurposes self.australian_resident_for_tax_purposes if self.australian_resident_for_tax_purposes
        b.TaxFreeThresholdClaimed self.tax_free_threshold_claimed if self.tax_free_threshold_claimed
        b.TaxOffsetEstimatedAmount self.tax_offset_estimated_amount if self.tax_offset_estimated_amount
        b.HasHELPDebt self.has_help_debt if self.has_help_debt
        b.HasSFSSDebt self.has_sfss_debt if self.has_sfss_debt
        b.UpwardVariationTaxWithholdingAmount self.upward_variation_tax_withholding_amount if self.upward_variation_tax_withholding_amount
        b.EligibleToReceiveLeaveLoading self.eligible_to_receive_leave_loading if self.eligible_to_receive_leave_loading
        b.ApprovedWithholdingVariationPercentage self.approved_withholding_variation_percentage if self.approved_withholding_variation_percentage
      }
    end

    def self.from_xml(tax_declaration_element, gateway = nil)
      tax_declaration = TaxDeclaration.new
      tax_declaration.gateway = gateway
      tax_declaration_element.children.each do |element|
        case(element.name)
          when "EmploymentBasis" then tax_declaration.employment_basis = element.text
          when "TFNPendingOrExemptionHeld" then tax_declaration.tfn_pending_or_exemption_held = element.text
          when "TaxFileNumber" then tax_declaration.tax_file_number = element.text
          when "AustralianResidentForTaxPurposes" then tax_declaration.australian_resident_for_tax_purposes = element.text
          when "TaxFreeThresholdClaimed" then tax_declaration.tax_free_threshold_claimed = element.text
          when "TaxOffsetEstimatedAmount" then tax_declaration.tax_offset_estimated_amount = element.text
          when "HasHELPDebt" then tax_declaration.has_help_debt = element.text
          when "HasSFSSDebt" then tax_declaration.has_sfss_debt = element.text
          when "UpwardVariationTaxWithholdingAmount" then tax_declaration.upward_variation_tax_withholding_amount = element.text
          when "EligibleToReceiveLeaveLoading" then tax_declaration.eligible_to_receive_leave_loading = element.text
          when "ApprovedWithholdingVariationPercentage" then tax_declaration.approved_withholding_variation_percentage = element.text
        end
      end
      tax_declaration
    end

    def ==(other) [ :employment_basis, :tfn_pending_or_exemption_held, :tax_file_number, :australian_resident_for_tax_purposes, :tax_free_threshold_claimed, :tax_offset_estimated_amount, :has_help_debt, :has_sfss_debt, :upward_variation_tax_withholding_amount, :eligible_to_receive_leave_loading, :approved_withholding_variation_percentage, :updated_date_utc ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
