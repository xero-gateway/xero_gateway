require File.dirname(__FILE__) + '/../test_helper'

class CreateInvoiceTest < Test::Unit::TestCase
  include IntegrationTestMethods
  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
    end
  end
  
  def test_create_invoice
    example_invoice = dummy_invoice
    
    result = @gateway.create_invoice(example_invoice)
    assert result.success?
    assert !result.invoice.id.nil?
    assert result.invoice.invoice_number == example_invoice.invoice_number
  end
end