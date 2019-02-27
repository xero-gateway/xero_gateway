module XeroGateway
  class Contact < BaseRecord
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    CONTACT_STATUS = {
      'ACTIVE' =>     'Active',
      'DELETED' =>    'Deleted'
    } unless defined?(CONTACT_STATUS)

    attr_accessor :gateway, :errors

    attributes({
      "ContactID" => :string,
      "ContactNumber" => :string,
      "AccountNumber" => :string,
      "ContactStatus" => :string,
      "Name" => :string,
      "FirstName" => :string,
      "LastName" => :string,
      "EmailAddress" => :string,
      "Addresses" => [Address, { :omit_if_empty => true }],
      "Phones" => [Phone],
      "BankAccountDetails" => :string,
      "TaxNumber" => :string,
      "AccountsReceivableTaxType" => :string,
      "AccountsPayableTaxType" => :string,
      "ContactGroups"  => :string,
      "IsCustomer" => :boolean,
      "IsSupplier" => :boolean,
      "DefaultCurrency" => :string,
      "UpdatedDateUTC" => :datetime_utc,
      "ContactPersons" => [ContactPerson],
      "BrandingTheme" => BrandingTheme
    })

    readonly_attributes "IsCustomer", "IsSupplier", "BrandingTheme"

    { :updated_at => :updated_date_utc,
      :status => :contact_status,
      :email => :email_address }.each do |alt, orig|
      alias_method alt, orig 
      alias_method "#{alt}=", "#{orig}="
    end

    def initialize(params = {})
      super

      @errors ||= []
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

    def add_contact_person(contact_person_params = {})
      self.contact_persons ||= []
      self.contact_persons << ContactPerson.new(contact_person_params)
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

  end
end
