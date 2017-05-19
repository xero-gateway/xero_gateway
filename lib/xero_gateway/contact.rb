module XeroGateway
  class Contact
    include Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    CONTACT_STATUS = {
      'ACTIVE' =>     'Active',
      'DELETED' =>    'Deleted'
    } unless defined?(CONTACT_STATUS)

    # Xero::Gateway associated with this contact.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    attr_accessor :contact_id, :contact_number, :account_number, :status, :name, :first_name, :last_name, :email, :addresses, :phones, :updated_at,
                  :bank_account_details, :tax_number, :accounts_receivable_tax_type, :accounts_payable_tax_type, :is_customer, :is_supplier,
                  :default_currency, :contact_groups


    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @phones ||= []
      @addresses ||= nil
    end

    def address=(address)
      self.addresses = [address]
    end

    def address
      self.addresses    ||= []
      self.addresses[0] ||= Address.new
    end

    # Helper method to add a new address object to this contact.
    #
    # Usage:
    #  contact.add_address({
    #    :address_type =>   'STREET',
    #    :line_1 =>         '100 Queen Street',
    #    :city =>           'Brisbane',
    #    :region =>         'QLD',
    #    :post_code =>      '4000',
    #    :country =>        'Australia'
    #  })
    def add_address(address_params)
      self.addresses << Address.new(address_params)
    end

    def phone=(phone)
      self.phones = [phone]
    end

    def phone
      if @phones.size > 1
        @phones.detect {|p| p.phone_type == 'DEFAULT'} || phones[0]
      else
        @phones[0] ||= Phone.new
      end
    end

    # Helper method to add a new phone object to this contact.
    #
    # Usage:
    #  contact.add_phone({
    #    :phone_type =>   'MOBILE',
    #    :number =>       '0400123123'
    #  })
    def add_phone(phone_params = {})
      self.phones << Phone.new(phone_params)
    end

    # Validate the Contact record according to what will be valid by the gateway.
    #
    # Usage:
    #  contact.valid?     # Returns true/false
    #
    #  Additionally sets contact.errors array to an array of field/error.
    def valid?
      @errors = []

      if !contact_id.nil? && contact_id !~ GUID_REGEX
        @errors << ['contact_id', 'must be blank or a valid Xero GUID']
      end

      if status && !CONTACT_STATUS[status]
        @errors << ['status', "must be one of #{CONTACT_STATUS.keys.join('/')}"]
      end

      unless name
        @errors << ['name', "can't be blank"]
      end

      # Make sure all addresses are correct.
      unless addresses.all? { | address | address.valid? }
        @errors << ['addresses', 'at least one address is invalid']
      end

      # Make sure all phone numbers are correct.
      unless phones.all? { | phone | phone.valid? }
        @errors << ['phones', 'at least one phone is invalid']
      end

      @errors.size == 0
    end

    # General purpose create/save method.
    # If contact_id and contact_number are nil then create, otherwise, attempt to save.
    def save
      if contact_id.nil? && contact_number.nil?
        create
      else
        update
      end
    end

    # Creates this contact record (using gateway.create_contact) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def create
      raise NoGatewayError unless gateway
      gateway.create_contact(self)
    end

    # Creates this contact record (using gateway.update_contact) with the associated gateway.
    # If no gateway set, raise a NoGatewayError exception.
    def update
      raise NoGatewayError unless gateway
      gateway.update_contact(self)
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.Contact {
        b.ContactID self.contact_id if self.contact_id
        b.ContactNumber self.contact_number if self.contact_number
        b.AccountNumber self.account_number if self.account_number
        b.Name self.name if self.name
        b.EmailAddress self.email if self.email
        b.FirstName self.first_name if self.first_name
        b.LastName self.last_name if self.last_name
        b.BankAccountDetails self.bank_account_details if self.bank_account_details
        b.TaxNumber self.tax_number if self.tax_number
        b.AccountsReceivableTaxType self.accounts_receivable_tax_type if self.accounts_receivable_tax_type
        b.AccountsPayableTaxType self.accounts_payable_tax_type if self.accounts_payable_tax_type
        b.ContactGroups if self.contact_groups
        b.IsCustomer true if self.is_customer
        b.IsSupplier true if self.is_supplier
        b.DefaultCurrency if self.default_currency
        b.Addresses {
          addresses.each { |address| address.to_xml(b) }
        } unless addresses.nil?
        b.Phones {
          phones.each { |phone| phone.to_xml(b) }
        } if self.phones.any?
      }
    end

    # Take a Contact element and convert it into an Contact object
    def self.from_xml(contact_element, gateway = nil)
      contact = Contact.new(:gateway => gateway)
      contact_element.children.each do |element|
        case(element.name)
          when "ContactID" then contact.contact_id = element.text
          when "ContactNumber" then contact.contact_number = element.text
          when "AccountNumber" then contact.account_number = element.text
          when "ContactStatus" then contact.status = element.text
          when "Name" then contact.name = element.text
          when "FirstName" then contact.first_name = element.text
          when "LastName" then contact.last_name = element.text
          when "EmailAddress" then contact.email = element.text
          when "Addresses" then element.children.each { |address_element| contact.addresses ||= []; contact.addresses << Address.from_xml(address_element) }
          when "Phones" then element.children.each { |phone_element| contact.phones << Phone.from_xml(phone_element) }
          when "BankAccountDetails" then contact.bank_account_details = element.text
          when "TaxNumber" then contact.tax_number = element.text
          when "AccountsReceivableTaxType" then contact.accounts_receivable_tax_type = element.text
          when "AccountsPayableTaxType" then contact.accounts_payable_tax_type = element.text
          when "ContactGroups" then contact.contact_groups = element.text
          when "IsCustomer" then contact.is_customer = (element.text == "true")
          when "IsSupplier" then contact.is_supplier = (element.text == "true")
          when "DefaultCurrency" then contact.default_currency = element.text
          when "UpdatedDateUTC" then contact.updated_at = parse_date_time(element.text)
        end
      end
      contact
    end

    def ==(other)
      [ :contact_id, :contact_number, :account_number, :status, :name, :first_name, :last_name, :email, :addresses, :phones, :updated_at,
        :bank_account_details, :tax_number, :accounts_receivable_tax_type, :accounts_payable_tax_type, :is_customer, :is_supplier,
        :default_currency, :contact_groups ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
