require File.dirname(__FILE__) + '/../test_helper'

class GetInvoicesTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|url, params| url =~ /invoices$/ }.returns(get_file_as_string("invoices.xml"))          
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
    end
  end
  
  def test_get_invoices
    # Make sure there is an invoice in Xero to retrieve
    invoice = @gateway.create_invoice(dummy_invoice).invoice
    
    result = @gateway.get_invoices
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?  
    assert result.invoices.collect {|i| i.invoice_number}.include?(invoice.invoice_number)
  end
  
  def test_get_invoices_with_modified_since_date
    # Create a test invoice
    invoice = dummy_invoice
    @gateway.create_invoice(invoice)
    
    # Check that it is returned
    result = @gateway.get_invoices(Date.today - 1)
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?    
    assert result.request_params.keys.include?(:modifiedSince) # make sure the flag was sent
    assert result.invoices.collect {|response_invoice| response_invoice.invoice_number}.include?(invoice.invoice_number)
  end  
  
  # Make sure that a reference to gateway is passed when the get_invoices response is parsed.
  def test_get_contacts_gateway_reference
    result = @gateway.get_invoices
    assert(result.success?)
    assert_not_equal(0, result.invoices.size)
    
    result.invoices.each do | invoice |
      assert(invoice.gateway === @gateway)
    end
  end
  
end