require File.join(File.dirname(__FILE__), '../test_helper.rb')

class AccountTest < Test::Unit::TestCase
  # Tests that an account can be converted into XML that Xero can understand, and then converted back to an account
  def test_build_and_parse_xml
    account = create_test_account
    
    # Generate the XML message
    account_as_xml = account.to_xml

    # Parse the XML message and retrieve the account element
    account_element = REXML::XPath.first(REXML::Document.new(account_as_xml), "/Account")

    # Build a new account from the XML
    result_account = XeroGateway::Account.from_xml(account_element)
    
    # Check the account details
    assert_equal account, result_account
  end
  
  
  private
  
  def create_test_account
    account = XeroGateway::Account.new(:account_id => "57cedda9")
    account.code = "200"
    account.name = "Sales"
    account.type = "REVENUE"
    account.tax_type = "OUTPUT"
    account.description = "Income from any normal business activity"
    account.enable_payments_to_account = false
    
    account
  end
end
