module XeroGateway
  class Response
    attr_accessor :response_id, :status, :errors, :provider, :date_time, :response_item, :request_params, :request_xml, :response_xml
    
    alias_method :invoice, :response_item
    alias_method :invoices, :response_item
    alias_method :contact, :response_item
    alias_method :contacts, :response_item
    alias_method :accounts, :response_item


    
    def initialize(params = {})
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
      
      @errors ||= []
    end    
    
    def success?
      status == "OK"
    end
    
    def error
      errors.blank? ? nil : errors[0]
    end
  end
end