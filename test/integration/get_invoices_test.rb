require File.dirname(__FILE__) + '/../test_helper'

class GetInvoicesTest < Test::Unit::TestCase
  include TestHelper
  
  INVALID_INVOICE_ID = "99999999-9999-9999-9999-999999999999" unless defined?(INVALID_INVOICE_ID)
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /invoices$/ }.returns(get_file_as_string("invoices.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("create_invoice.xml"))

      # Get an invoice with an invalid ID number.
      @gateway.stubs(:http_get).with {|client, url, params| url =~ /invoice$/ && params[:invoiceID] == "99999999-9999-9999-9999-999999999999" }.returns(get_file_as_string("invoice_not_found_error.xml"))
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
  
  def test_line_items_downloaded_set_correctly
    # No line items.
    response = @gateway.get_invoices
    assert_equal(true, response.success?)
    
    invoice = response.invoices.first
    assert_kind_of(XeroGateway::Invoice, invoice)
    assert_equal(false, invoice.line_items_downloaded?)
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
  
  # Test to make sure that we correctly error when an invoice doesn't have an ID.
  # This should usually never be ecountered, but might if a draft invoice is deleted from Xero.
  def test_to_ensure_that_an_invoice_with_invalid_id_errors
    # Make sure there is an invoice to retrieve, even though we will mangle it later.
    invoice = @gateway.create_invoice(dummy_invoice).invoice
    
    result = @gateway.get_invoices
    assert_equal(true, result.success?)
    
    invoice = result.invoices.first
    assert_equal(false, invoice.line_items_downloaded?)
    
    # Mangle invoice_id to invalid one.
    invoice.invoice_id = INVALID_INVOICE_ID
    
    # Make sure we fail here.
    line_items = nil
    assert_raise(XeroGateway::Invoice::InvoiceNotFoundError) { line_items = invoice.line_items }
    assert_nil(line_items)
    
  end
  
end