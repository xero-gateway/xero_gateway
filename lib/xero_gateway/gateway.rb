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
    
      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the contacts to the response
      if response.success?
        response.response_item = []
        REXML::XPath.each(doc, "/Response/Contacts/Contact") do |contact_element|
          response.response_item << XeroGateway::Messages::ContactMessage.from_xml(contact_element)
        end
      end
    
      # Add the request and response XML to the response object
      response.request_params = request_params
      response.response_xml = response_xml
      response
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
    #    create_contact(contact)
    def create_contact(contact)
      request_xml = XeroGateway::Messages::ContactMessage.build_xml(contact)      
      response_xml = http_put("#{@xero_url}/contact", request_xml, {})

      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the invoice to the response
      if response.success?
        response.response_item = XeroGateway::Messages::ContactMessage.from_xml(REXML::XPath.first(doc, "/Response/Contact"))
      end
    
      # Add the request and response XML to the response object
      response.request_xml = request_xml
      response.response_xml = response_xml
    
      response      
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

      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the invoices to the response
      if response.success?
        response.response_item = []
        REXML::XPath.first(doc, "/Response/Invoices").children.each do |invoice_element|
          response.response_item << XeroGateway::Messages::InvoiceMessage.from_xml(invoice_element)
        end
      end
    
      # Add the request and response XML to the response object
      response.request_params = request_params
      response.response_xml = response_xml
      response      
    end
  
    # Creates an invoice in Xero based on an invoice object
    #
    # Usage : 
    #
    #    invoice = XeroGateway::Invoice.new({
    #      :invoice_type => "ACCREC",
    #      :due_date => 1.month.from_now,
    #      :invoice_number => "YOUR INVOICE NUMBER",
    #      :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
    #      :includes_tax => false,
    #      :sub_total => 1000,
    #      :total_tax => 125,
    #      :total => 1125
    #    })
    #    invoice.contact = XeroGateway::Contact.new(:name => "THE NAME OF THE CONTACT")
    #    invoice.contact.phone.number = "12345"
    #    invoice.contact.address.line_1 = "LINE 1 OF THE ADDRESS"    
    #    invoice.line_items << XeroGateway::LineItem.new(
    #      :description => "THE DESCRIPTION OF THE LINE ITEM",
    #      :unit_amount => 100,
    #      :tax_amount => 12.5,
    #      :line_amount => 125,
    #      :tracking_category => "THE TRACKING CATEGORY FOR THE LINE ITEM",
    #      :tracking_option => "THE TRACKING OPTION FOR THE LINE ITEM"
    #    )
    #
    #    create_invoice(invoice)
    def create_invoice(invoice)
      request_xml = XeroGateway::Messages::InvoiceMessage.build_xml(invoice)      
      response_xml = http_put("#{@xero_url}/invoice", request_xml)

      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the invoice to the response
      if response.success?
        response.response_item = XeroGateway::Messages::InvoiceMessage.from_xml(REXML::XPath.first(doc, "/Response/Invoice"))
      end
    
      # Add the request and response XML to the response object
      response.request_xml = request_xml
      response.response_xml = response_xml
    
      response
    end

    #
    # Gets all accounts for a specific organization in Xero.
    #
    def get_accounts
      response_xml = http_get("#{xero_url}/accounts")
      
      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the accounts to the response
      response.response_item = []
      REXML::XPath.first(doc, "/Response/Accounts").children.each do |account_element|
        response.response_item << XeroGateway::Messages::AccountMessage.from_xml(account_element)
      end
      
      # Add the request and response XML to the response object
      response.response_xml = response_xml
      response
    end



    private

    def get_invoice(invoice_id = nil, invoice_number = nil)
      request_params = invoice_id ? {:invoiceID => invoice_id} : {:invoiceNumber => invoice_number}
      response_xml = http_get("#{@xero_url}/invoice", request_params)
    
      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the invoice to the response
      response.response_item = XeroGateway::Messages::InvoiceMessage.from_xml(REXML::XPath.first(doc, "/Response/Invoice")) if response.success?
    
      # Add the request and response XML to the response object
      response.request_params = request_params
      response.response_xml = response_xml
      response
    end

    def get_contact(contact_id = nil, contact_number = nil)
      request_params = contact_id ? {:contactID => contact_id} : {:contactNumber => contact_number}
      response_xml = http_get("#{@xero_url}/contact", request_params)
    
      doc = REXML::Document.new(response_xml)
    
      # Create the response object
      response = build_response(doc)

      # Add the invoice to the response
      response.response_item = XeroGateway::Messages::ContactMessage.from_xml(REXML::XPath.first(doc, "/Response/Contact")) if response.success?
    
      # Add the request and response XML to the response object
      response.request_params = request_params
      response.response_xml = response_xml
      response
    end
    
    
    
    def build_response(response_document)
      response = XeroGateway::Response.new({
        :id => REXML::XPath.first(response_document, "/Response/ID").text,
        :status => REXML::XPath.first(response_document, "/Response/Status").text,
        :provider => REXML::XPath.first(response_document, "/Response/ProviderName").text,
        :date_time => REXML::XPath.first(response_document, "/Response/DateTimeUTC").text,
      })
    
      # Add any errors to the response object
      if !response.success?
        REXML::XPath.each(response_document, "/Response/Error") do |error|
          response.errors << {
            :date_time => REXML::XPath.first(error, "/DateTime").text,
            :type => REXML::XPath.first(error, "/ExceptionType").text,
            :message => REXML::XPath.first(error, "/Message").text           
          }          
        end
      end
    
      response      
    end
  end
end
