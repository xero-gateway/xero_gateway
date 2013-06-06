module XeroGateway::Payroll
  class PayTemplate
    
    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)
    
    attr_accessor :gateway
    
    # Any errors that occurred when the #valid? method called.
    attr_reader :errors
    
    attr_accessor :earnings_lines
    
     def initialize(params = {})
      @errors ||= []

      params = {}.merge(params)
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @earnings_lines ||= []
    end
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.PayTemplate {
      	b.EarningsLines self.earnings_lines if self.earnings_lines
      }
    end
    
    def self.from_xml(pay_template_element, gateway = nil)
      pay_template = PayTemplate.new
      pay_template_element.children.each do |element|
        case(element.name)
          when "EarningsLines" then element.children.each {|child| pay_template.earnings_lines << EarningsLine.from_xml(child, gateway) }
        end
      end
      pay_template
    end

    def ==(other)
      [ :earnings_lines ].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
