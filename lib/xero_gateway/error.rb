module XeroGateway
  class Error
    attr_accessor :description, :date_time, :type, :message
    
    def initialize(params = {})
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def ==(other)
      [:description, :date_time, :type, :message].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

    # pass a REXML::Element error object to 
    # have returned a new Error object
    def self.parse(error_element)
      description = REXML::XPath.first(error_element, "Description")
      date = REXML::XPath.first(error_element, "//DateTime")
      type = REXML::XPath.first(error_element, "//ExceptionType")
      message = REXML::XPath.first(error_element, "//Message")
      Error.new(
        :description => (description.text if description),
        :date_time => (date.text if date),
        :type => (type.text if type),
        :message => (message.text if message)
      )
    end

  end
end
