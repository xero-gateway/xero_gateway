module XeroGateway
  class User
    # Xero::Gateway associated with this user.
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :user_id, :first_name
        
    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.User {
        b.UserID self.user_id if self.user_id
        b.FirstName self.first_name if self.first_name
        
      }
    end
    
    # Should add other fields based on Pivotal: 49575441
    def self.from_xml(user_element)
      user = User.new
      user_element.children.each do |element|
        case(element.name)
          when "UserID" then user.user_id = element.text
          when "FirstName" then user.first_name = element.text
          when "Employees" then element.children.each {|employee_element| user.employees << Employee.from_xml_to_user(employee_element)}

        end
      end
      employee
    end
    
    def ==(other)
      [:user_id, :first_name].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end    
        
  end
end
