module XeroGateway
  class LineItem
    include Money
    
    TAX_TYPE = {
      'NONE' =>             'No GST',
      'EXEMPTINPUT' =>      'VAT on expenses exempt from VAT (UK only)',
      'INPUT' =>            'GST on expenses',
      'SRINPUT' =>          'VAT on expenses',
      'ZERORATEDINPUT' =>   'Expense purchased from overseas (UK only)',
      'RRINPUT' =>          'Reduced rate VAT on expenses (UK Only)', 
      'EXEMPTOUTPUT' =>     'VAT on sales exempt from VAT (UK only)',
      'OUTPUT' =>           'OUTPUT',
      'SROUTPUT' =>         'SROUTPUT',
      'ZERORATEDOUTPUT' =>  'Sales made from overseas (UK only)',
      'RROUTPUT' =>         'Reduced rate VAT on sales (UK Only)',
      'ZERORATED' =>        'Zero-rated supplies/sales from overseas (NZ Only)'
    } unless defined?(TAX_TYPE)

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # All accessible fields
    attr_accessor :line_item_id, :description, :quantity, :unit_amount, :tax_type, :tax_amount, :line_amount, :account_code, :tracking_category, :tracking_option
    
    def initialize(params = {})
      @errors ||= []
      @quantity = 1
      
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end    
    
    # Validate the LineItem record according to what will be valid by the gateway.
    #
    # Usage: 
    #  line_item.valid?     # Returns true/false
    #  
    #  Additionally sets line_item.errors array to an array of field/error.
    def valid?
      @errors = []
      
      if !line_item_id.nil? && line_item_id !~ GUID_REGEX
        @errors << ['line_item_id', 'must be blank or a valid Xero GUID']
      end
      
      unless description
        @errors << ['description', "can't be blank"]
      end
      
      unless (quantity * unit_amount) == line_amount
        @errors << ['line_amount', "must equal quantity * unit_amount"]
      end
      
      if tax_type && !TAX_TYPE[tax_type]
        @errors << ['tax_type', "must be one of #{TAX_TYPE.keys.join('/')}"]
      end
      
      @errors.size == 0
    end
    
    
    def to_xml(b = Builder::XmlMarkup.new)
      b.LineItem {
        b.Description description
        b.Quantity quantity if quantity
        b.UnitAmount LineItem.format_money(unit_amount)
        b.TaxType tax_type if tax_type
        b.TaxAmount LineItem.format_money(tax_amount) if tax_amount
        b.LineAmount LineItem.format_money(line_amount)
        b.AccountCode account_code if account_code
        b.Tracking {
          b.TrackingCategory {
            b.Name tracking_category
            b.Option tracking_option
          }
        }      
      }
    end
    
    def self.from_xml(line_item_element)
      line_item = LineItem.new
      line_item_element.children.each do |element|
        case(element.name)
          when "LineItemID" then line_item.line_item_id = element.text
          when "Description" then line_item.description = element.text
          when "Quantity" then line_item.quantity = element.text.to_i
          when "UnitAmount" then line_item.unit_amount = BigDecimal.new(element.text)
          when "TaxType" then line_item.tax_type = element.text
          when "TaxAmount" then line_item.tax_amount = BigDecimal.new(element.text)
          when "LineAmount" then line_item.line_amount = BigDecimal.new(element.text)
          when "AccountCode" then line_item.account_code = element.text
          when "Tracking" then
          if element.elements['TrackingCategory']
            line_item.tracking_category = element.elements['TrackingCategory/Name'].text
            line_item.tracking_option = element.elements['TrackingCategory/Option'].text
          end
        end
      end
      line_item
    end    

    def ==(other)
      [:description, :quantity, :unit_amount, :tax_type, :tax_amount, :line_amount, :account_code, :tracking_category, :tracking_option].each do |field|
        puts field if send(field) != other.send(field) 
        return false if send(field) != other.send(field)
      end
      return true
    end
  end  
end
