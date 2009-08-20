require "rubygems"

require 'test/unit'
require 'mocha'

require 'libxml'

require File.dirname(__FILE__) + '/../lib/xero_gateway.rb'

module TestHelper
  # The integration tests can be run against the Xero test environment.  You mush have a company set up in the test
  # environment, and you must have set up a customer key for that account.
  #
  # You can then run the tests against the test environment using the commands (linux or mac):
  # export STUB_XERO_CALLS=false
  # export API_KEY=[your_api_key]
  # export CUSTOMER_KEY=[your_customer_key]
  # rake test
  STUB_XERO_CALLS = ENV["STUB_XERO_CALLS"].nil? ? true : (ENV["STUB_XERO_CALLS"] == "true") unless defined? STUB_XERO_CALLS
  
  API_KEY = ENV["API_KEY"] unless defined? API_KEY
  CUSTOMER_KEY = ENV["CUSTOMER_KEY"] unless defined? CUSTOMER_KEY
  
  # Helper constant for checking regex
  GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

  
  def dummy_invoice(with_line_items = true)
     invoice = XeroGateway::Invoice.new({
       :invoice_type => "ACCREC",
       :date => Time.now,
       :due_date => Date.today + 20,
       :invoice_number => STUB_XERO_CALLS ? "INV-0001" : "#{Time.now.to_f}",
       :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
       :line_items_downloaded => with_line_items
     })
     invoice.contact = dummy_contact
     if with_line_items
       invoice.line_items << XeroGateway::LineItem.new(
         :description => "THE DESCRIPTION OF THE LINE ITEM",
         :unit_amount => 1000,
         :tax_amount => 125,
         :tracking => ["THE TRACKING CATEGORY FOR THE LINE ITEM", "THE TRACKING OPTION FOR THE LINE ITEM"]
       )
     end
     invoice
  end
      
  def dummy_contact
    unique_id = Time.now.to_f
    contact = XeroGateway::Contact.new(:name => STUB_XERO_CALLS ? "CONTACT NAME" : "THE NAME OF THE CONTACT #{unique_id}")
    contact.email = "bob#{unique_id}@example.com"
    contact.phone.number = "12345"
    contact.address.line_1 = "LINE 1 OF THE ADDRESS"
    contact.address.line_2 = "LINE 2 OF THE ADDRESS"
    contact.address.line_3 = "LINE 3 OF THE ADDRESS"
    contact.address.line_4 = "LINE 4 OF THE ADDRESS"
    contact.address.city = "WELLINGTON"
    contact.address.region = "WELLINGTON"
    contact.address.country = "NEW ZEALAND"
    contact.address.post_code = "6021"

    contact
  end
  
  def get_file_as_string(filename)
    data = ''
    f = File.open(File.dirname(__FILE__) + "/stub_responses/" + filename, "r") 
    f.each_line do |line|
      data += line
    end
    f.close
    return data
  end
end