module XeroGateway
  class User
    # Xero::Gateway associated with this user.
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :first_name, :date_of_birth, :email, :first_name, :gender, :home_phone,
                  :known_as, :last_name, :marital_status, :middle_name, :nationality, :notes, :personal_email,
                  :personal_mobile_number, :tax_file_number, :title, :trading_name
        
    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.User {
        b.FirstName self.first_name if self.first_name
        b.DateOfBirth self.date_of_birth if self.date_of_birth
        b.Email self.email if self.email
        b.FirstName self.first_name if self.first_name
        b.Gender self.gender if self.gender
        b.LastName self.last_name if self.last_name
        b.MiddleNames self.middle_name if self.middle_name
        b.TaxFileNumber self.tax_file_number if self.tax_file_number
        b.Title self.title if self.title
      }
    end
    
    # Should add other fields based on Pivotal: 49575441
    def self.from_xml(user_element)
      user = User.new
      user_element.children.each do |element|
        case(element.name)
          when "DateOfBirth" then user.date_of_birth = element.text
          when "Email" then user.email = element.text
          when "FirstName" then user.first_name = element.text
          when "Gender" then user.gender = element.text
          when "LastName" then user.last_name = element.text
          when "MiddleNames" then user.middle_name = element.text
          when "TaxFileNumber" then user.tax_file_number = element.text
          when "Title" then user.title = element.text
        end
      end
      user
    end
    
    def ==(other)
      [:user_id, :first_name].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end    
        
  end
end
