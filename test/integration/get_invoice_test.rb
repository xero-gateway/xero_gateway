require File.dirname(__FILE__) + '/../test_helper'

class GetInvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
    end
  end
  
  def test_get_invoice
    # Make sure there is an invoice in Xero to retrieve
    invoice = @gateway.create_invoice(dummy_invoice).invoice

    result = @gateway.get_invoice_by_id(invoice.invoice_id)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?    
    assert_equal result.invoice.invoice_number, invoice.invoice_number

    result = @gateway.get_invoice_by_number(invoice.invoice_number)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?    
    assert_equal result.invoice.invoice_id, invoice.invoice_id
  end
  
  def test_line_items_downloaded_set_correctly
    # Make sure there is an invoice in Xero to retrieve.
    example_invoice = @gateway.create_invoice(dummy_invoice).invoice
    
    # No line items.
    response = @gateway.get_invoice_by_id(example_invoice.invoice_id)
    assert_equal(true, response.success?)
    
    invoice = response.invoice
    assert_kind_of(XeroGateway::LineItem, invoice.line_items.first)
    assert_kind_of(XeroGateway::Invoice, invoice)
    assert_equal(true, invoice.line_items_downloaded?)
  end
  
end