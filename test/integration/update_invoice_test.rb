require File.dirname(__FILE__) + '/../test_helper'

class UpdateInvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Invoices$/ }.returns(get_file_as_string("create_invoice.xml"))          
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /Invoices$/ }.returns(get_file_as_string("invoice.xml"))          
    end
  end
  
  def test_update_invoice
    invoice = @gateway.create_invoice(dummy_invoice).invoice
    
    today = Date.today
    invoice.due_date = today
    
    result = @gateway.update_invoice(invoice)
    
    assert result.success?
    assert !result.request_xml.nil?
    assert !result.response_xml.nil?    
    assert_equal invoice.invoice_id, result.invoice.invoice_id
    assert_equal today, result.invoice.due_date if !STUB_XERO_CALLS
  end
end