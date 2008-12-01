# Copyright (c) 2008 Tim Connor <tlconnor@gmail.com>
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require File.dirname(__FILE__) + '/../test_helper'

class GatewayTest < Test::Unit::TestCase
  # If false, the tests will be run against the Xero test environment
  STUB_XERO_CALLS = true
  
  # If the requests are not stubbed, enter your API key and you test company customer key here
  API_KEY = "YOUR API KEY"
  CUSTOMER_KEY = "YOUR CUSTOMER KEY"

  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      # Stub out the HTTP request
      @gateway.stubs(:http_get).with {|url, params| url =~ /contact$/ }.returns(get_file_as_string("contact.xml"))
      @gateway.stubs(:http_get).with {|url, params| url =~ /contacts$/ }.returns(get_file_as_string("contacts.xml"))
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoices$/ }.returns(get_file_as_string("invoices.xml"))          
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /contact$/ }.returns(get_file_as_string("contact.xml"))          


    end
  end
  
  def dummy_invoice
     invoice = XeroGateway::Invoice.new({
       :invoice_type => "ACCREC",
       :due_date => Date.today + 20,
       :invoice_number => STUB_XERO_CALLS ? "INV-0001" : "#{Time.now.to_i}",
       :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
       :sub_total => 1000,
       :total_tax => 125,
       :total => 1125
     })
     invoice.contact = dummy_contact
     invoice.line_items << XeroGateway::LineItem.new(
       :description => "THE DESCRIPTION OF THE LINE ITEM",
       :unit_amount => 1000,
       :tax_amount => 125,
       :line_amount => 1000,
       :tracking_category => "THE TRACKING CATEGORY FOR THE LINE ITEM",
       :tracking_option => "THE TRACKING OPTION FOR THE LINE ITEM"
     )
     invoice
  end
  
  def dummy_contact
    contact = XeroGateway::Contact.new(:name => STUB_XERO_CALLS ? "CONTACT NAME" : "THE NAME OF THE CONTACT #{Time.now.to_i}")
    contact.contact_number = STUB_XERO_CALLS ? "12345" : "#{Time.now.to_i}"
    contact.email = "whoever@something.com"
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
  
  def test_create_and_get_contact
    contact = dummy_contact
    
    create_contact_result = @gateway.create_contact(contact)
    assert create_contact_result.success?
    
    contact_from_create_request = create_contact_result.contact
    assert contact_from_create_request.name == contact.name
    
    get_contact_by_id_result = @gateway.get_contact_by_id(contact_from_create_request.id)
    assert get_contact_by_id_result.success?
    assert get_contact_by_id_result.contact.name == contact.name

    get_contact_by_number_result = @gateway.get_contact_by_number(contact.contact_number)
    assert get_contact_by_number_result.success?
    assert get_contact_by_number_result.contact.name == contact.name
  end
    
  def test_create_and_get_invoice
    invoice = dummy_invoice
    
    result = @gateway.create_invoice(invoice)
    assert result.success?
    
    invoice_from_create_request = result.invoice
    assert invoice_from_create_request.invoice_number == invoice.invoice_number
    
    result = @gateway.get_invoice_by_id(invoice_from_create_request.id)
    assert result.success?
    assert result.invoice.invoice_number == invoice_from_create_request.invoice_number

    result = @gateway.get_invoice_by_number(invoice_from_create_request.invoice_number)
    assert result.success?
    assert result.invoice.id == invoice_from_create_request.id
  end
  
  def test_get_contacts
    result = @gateway.get_contacts
    assert result.success?
    assert result.contacts.size > 0
  end
  
  def test_get_invoices
    # Create a test invoice
    invoice = dummy_invoice
    @gateway.create_invoice(invoice)
    
    # Check that it is returned
    result = @gateway.get_invoices
    assert result.success?
    assert result.invoices.collect {|response_invoice| response_invoice.invoice_number}.include?(invoice.invoice_number)
  end
  
  def test_get_invoices_with_modified_since_date
    # Create a test invoice
    invoice = dummy_invoice
    @gateway.create_invoice(invoice)
    
    # Check that it is returned
    result = @gateway.get_invoices(Date.today - 1)
    assert result.success?
    assert result.invoices.collect {|response_invoice| response_invoice.invoice_number}.include?(invoice.invoice_number)
  end
  
  
end