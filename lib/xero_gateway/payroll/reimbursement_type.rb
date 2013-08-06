module XeroGateway::Payroll
  class ReimbursementType
  
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors  
    
    attr_accessor :name, :account_code, :reimbursement_type_id
    
    def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def valid?
      @errors = []
      
      if !reimbursement_type_id.blank? && reimbursement_type_id !~ GUID_REGEX
        @errors << ['employee_id', 'invalid ID']
      end
      
      if name.blank?
        @errors << ['name', "can't be blank"]
      end 
      
      if account_code.blank?
        @errors << ['account_code', "can't be blank"]
      end 
      
      @errors.size == 0
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.ReimbursementType{
        b.Name self.name if self.name
        b.AccountCode self.account_code if self.account_code
        b.ReimbursementTypeID self.reimbursement_type_id if self.reimbursement_type_id
      }
    end 
    
    def self.from_xml(reimbursement_type_element, gateway = nil)
      reimbursement_type = ReimbursementType.new
      reimbursement_type_element.children.each do |element|
        case (element.name)
          when "Name" then reimbursement_type.name = element.text
          when "AccountCode" then reimbursement_type.account_code = element.text
          when "ReimbursementTypeID" then reimbursement_type.reimbursement_type_id = element.text
        end 
      end 
      reimbursement_type
    end 
    
    def ==(other)
      [:name, :account_code, :reimbursement_type].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end 
  end
end  
