module XeroGateway
  class Invoice
    # All accessible fields
    attr_accessor :id, :invoice_number, :invoice_type, :invoice_status, :date, :due_date, :reference, :tax_inclusive, :includes_tax, :sub_total, :total_tax, :total, :line_items, :contact
    
    def initialize(params = {})
      params = {
        :contact => Contact.new,
        :date => Time.now,
        :includes_tax => true,
        :tax_inclusive => true
      }.merge(params)
      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
      
      @line_items ||= []
    end    

    def ==(other)
      equal = true
      ["invoice_number", "invoice_type", "invoice_status", "reference", "tax_inclusive", "includes_tax", "sub_total", "total_tax", "total", "contact", "line_items"].each do |field|
        equal &&= (send(field) == other.send(field))
      end
      ["date", "due_date"].each do |field|
        equal &&= (send(field).to_s == other.send(field).to_s)
      end
      
      return equal
    end
  end
end
