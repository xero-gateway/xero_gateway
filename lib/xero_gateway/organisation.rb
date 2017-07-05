module XeroGateway
  class Organisation < BaseRecord
    attributes({
      "OrganisationID"        => :string,
      "Name" 	                => :string,     # Display name of organisation shown in Xero
      "LegalName"             => :string,	    # Organisation name shown on Reports
      "PaysTax" 	            => :boolean,    # Boolean to describe if organisation is registered with a local tax authority i.e. true, false
      "Version"   	          => :string,     # See Version Types
      "BaseCurrency"          => :string,     # Default currency for organisation. See Currency types
      "OrganisationType"      => :string,     # only returned for "real" (i.e non-demo) companies
      "OrganisationStatus"    => :string,
      "IsDemoCompany"         => :boolean,
      "APIKey"                => :string,     # returned if organisations are linked via Xero Network
      "CountryCode"           => :string,
      "TaxNumber"             => :string,
      "FinancialYearEndDay"   => :string,
      "FinancialYearEndMonth" => :string,
      "PeriodLockDate"        => :string,
      "CreatedDateUTC"        => :string,
      "ShortCode"             => :string,
      "Timezone"              => :string,
      "LineOfBusiness"        => :string,
      "Addresses"             => [Address]
    })

    def add_address(address_params)
      self.addresses ||= []
      self.addresses << Address.new(address_params)
    end
  end
end
