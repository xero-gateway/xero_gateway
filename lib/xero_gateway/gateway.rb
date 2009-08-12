module XeroGateway
  class Gateway
    include Http
      
    attr_accessor :xero_url, :customer_key, :api_key
  
    def initialize(params)
      @xero_url = params[:xero_url] || "https://networktest.xero.com/api.xro/1.0"
      @customer_key = params[:customer_key]
      @api_key = params[:api_key]
    end
  
    # Retrieve all contacts from Xero
    # Usage get_contacts(:type => :all, :sort => :name, :direction => :desc)
    def get_contacts(options = {})
      request_params = {}
      request_params[:type] = options[:type] if options[:type]
      request_params[:sortBy] = options[:sort] if options[:sort]      
      request_params[:direction] = options[:direction] if options[:direction]            
    
      response_xml = http_get("#{@xero_url}/contacts", request_params)
    
      parse_response(response_xml, :request_params => request_params)
    end
    
    # Retrieve a contact from Xero
    # Usage get_contact_by_id(contact_id)    
    def get_contact_by_id(contact_id)
      get_contact(contact_id)
    end

    # Retrieve a contact from Xero
    # Usage get_contact_by_id(contact_id)    
    def get_contact_by_number(contact_number)
      get_contact(nil, contact_number)
    end
    
    # Factory method for building new Contact objects associated with this gateway.
    def build_contact(contact = {})
      case contact
        when Contact then   contact.gateway = self
        when Hash then      contact = Contact.new(contact.merge({:gateway => self}))
      end
      contact
    end
    
    #
    # Creates a contact in Xero
    #
    # Usage : 
    #
    # contact = XeroGateway::Contact.new(:name => "THE NAME OF THE CONTACT #{Time.now.to_i}")
    # contact.email = "whoever@something.com"
    # contact.phone.number = "12345"
    # contact.address.line_1 = "LINE 1 OF THE ADDRESS"
    # contact.address.line_2 = "LINE 2 OF THE ADDRESS"
    # contact.address.line_3 = "LINE 3 OF THE ADDRESS"
    # contact.address.line_4 = "LINE 4 OF THE ADDRESS"
    # contact.address.city = "WELLINGTON"
    # contact.address.region = "WELLINGTON"
    # contact.address.country = "NEW ZEALAND"
    # contact.address.post_code = "6021"
    #
    # create_contact(contact)
    def create_contact(contact)
      save_contact(contact)
    end
    
    #
    # Updates an existing Xero contact
    #
    # Usage : 
    #
    # contact = xero_gateway.get_contact(some_contact_id)
    # contact.email = "a_new_email_ddress"
    #
    # xero_gateway.update_contact(contact)  
    def update_contact(contact)
      raise "contact_id or contact_number is required for updating contacts" if contact.contact_id.nil? and contact.contact_number.nil?
      save_contact(contact)
    end
    
    # Retrieves an invoice from Xero based on its GUID
    #
    # Usage : get_invoice_by_id("8c69117a-60ae-4d31-9eb4-7f5a76bc4947")
    def get_invoice_by_id(invoice_id)
      get_invoice(invoice_id)
    end

    # Retrieves an invoice from Xero based on its number
    #
    # Usage : get_invoice_by_number("OIT00526")
    def get_invoice_by_number(invoice_number)
      get_invoice(nil, invoice_number)
    end  
  
    # Retrieves all invoices from Xero
    #
    # Usage : get_invoices
    #         get_invoices(modified_since)
    def get_invoices(modified_since = nil)
      request_params = modified_since ? {:modifiedSince => modified_since.strftime("%Y-%m-%d")} : {}
    
      response_xml = http_get("#{@xero_url}/invoices", request_params)

      parse_response(response_xml, :request_params => request_params)
    end
    
    # Factory method for building new Invoice objects associated with this gateway.
    def build_invoice(invoice = {})
      case invoice
        when Invoice then     invoice.gateway = self
        when Hash then        invoice = Invoice.new(invoice.merge(:gateway => self))
      end
      invoice
    end
  
    # Creates an invoice in Xero based on an invoice object.
    #
    # Invoice and line item totals are calculated automatically.
    #
    # Usage : 
    #
    #    invoice = XeroGateway::Invoice.new({
    #      :invoice_type => "ACCREC",
    #      :due_date => 1.month.from_now,
    #      :invoice_number => "YOUR INVOICE NUMBER",
    #      :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
    #      :includes_tax => false
    #    })
    #    invoice.contact = XeroGateway::Contact.new(:name => "THE NAME OF THE CONTACT")
    #    invoice.contact.phone.number = "12345"
    #    invoice.contact.address.line_1 = "LINE 1 OF THE ADDRESS"    
    #    invoice.line_items << XeroGateway::LineItem.new(
    #      :description => "THE DESCRIPTION OF THE LINE ITEM",
    #      :unit_amount => 100,
    #      :tax_amount => 12.5,
    #      :tracking_category => "THE TRACKING CATEGORY FOR THE LINE ITEM",
    #      :tracking_option => "THE TRACKING OPTION FOR THE LINE ITEM"
    #    )
    #
    #    create_invoice(invoice)
    def create_invoice(invoice)
      request_xml = invoice.to_xml
      response_xml = http_put("#{@xero_url}/invoice", request_xml)

      response = parse_response(response_xml, :request_xml => request_xml)
      invoice.invoice_id = response.invoice.invoice_id if response.invoice && response.invoice.invoice_id
      
      response
    end

    #
    # Gets all accounts for a specific organization in Xero.
    #
    def get_accounts
      response_xml = http_get("#{xero_url}/accounts")
      parse_response(response_xml)
    end
    
    #
    # Returns a XeroGateway::AccountsList object that makes working with
    # the Xero list of accounts easier and allows caching the results.
    #
    def get_accounts_list(load_on_init = true)
      AccountsList.new(self, load_on_init)
    end

    #
    # Gets all tracking categories for a specific organization in Xero.
    #
    def get_tracking_categories
      response_xml = http_get("#{xero_url}/tracking")
      parse_response(response_xml)      
    end


    private

    def get_invoice(invoice_id = nil, invoice_number = nil)
      request_params = invoice_id ? {:invoiceID => invoice_id} : {:invoiceNumber => invoice_number}
      response_xml = http_get("#{@xero_url}/invoice", request_params)

      parse_response(response_xml, :request_params => request_params)
    end

    def get_contact(contact_id = nil, contact_number = nil)
      request_params = contact_id ? {:contactID => contact_id} : {:contactNumber => contact_number}
      response_xml = http_get("#{@xero_url}/contact", request_params)

      parse_response(response_xml, :request_params => request_params)
    end
    
    # Create or update a contact record based on if it has a contact_id or contact_number.
    def save_contact(contact)
      request_xml = contact.to_xml
      
      response_xml = nil
      if contact.contact_id.nil? && contact.contact_number.nil?
        # Create new contact record.
        response_xml = http_put("#{@xero_url}/contact", request_xml, {})
      else
        # Update existing contact record.
        response_xml = http_post("#{@xero_url}/contact", request_xml, {})
      end

      response = parse_response(response_xml, :request_xml => request_xml)
      contact.contact_id = response.contacts.contact_id if response.contacts && response.contacts.contact_id
      response
    end

    def parse_response(response_xml, request = {})
      doc = REXML::Document.new(response_xml)

      response = XeroGateway::Response.new

      response_element = REXML::XPath.first(doc, "/Response")
      
      if response_element.nil?
        # The Xero API documentation states that it will always return valid XML with
        # a response element, unless an invalid API key is provided.
        response.status = "INVALID_API_KEY"
      else
        response_element.children.each do |element|
          case(element.name)
            when "ID" then response.response_id = element.text
            when "Status" then response.status = element.text
            when "ProviderName" then response.provider = element.text
            when "DateTimeUTC" then response.date_time = element.text
            when "Contact" then response.response_item = Contact.from_xml(element)
            when "Invoice" then response.response_item = Invoice.from_xml(element)
            when "Contacts" then element.children.each {|child| response.response_item << Contact.from_xml(child) }
            when "Invoices" then element.children.each {|child| response.response_item << Invoice.from_xml(child) }
            when "Accounts" then element.children.each {|child| response.response_item << Account.from_xml(child) }
            when "Tracking" then element.children.each {|child| response.response_item << TrackingCategory.from_xml(child) }
            when "Errors" then element.children.each { |error| parse_error(error, response) }
          end
        end
      end
      
      response.request_params = request[:request_params]
      response.request_xml = request[:request_xml]
      response.response_xml = response_xml
      response
    end    

    def parse_error(error_element, response)
      response.errors << Error.new(
          :description => REXML::XPath.first(error_element, "Description").text,
          :date_time => REXML::XPath.first(error_element, "//DateTime").text,
          :type => REXML::XPath.first(error_element, "//ExceptionType").text,
          :message => REXML::XPath.first(error_element, "//Message").text           
      )
    end
  end  
end
