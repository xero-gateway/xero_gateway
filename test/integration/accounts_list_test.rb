require File.dirname(__FILE__) + '/../test_helper'

class AccountsListTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    # Always stub out calls for this integration test as we need to be able to control the data.
    @gateway.xero_url = "DUMMY_URL"    
    
    @gateway.stubs(:http_get).with {|client, url, params| url =~ /Accounts$/ }.returns(get_file_as_string("accounts.xml"))
  end
  
  def test_get_accounts_list
    accounts_list = @gateway.get_accounts_list
    assert_not_equal(0, accounts_list.accounts.size)
  end  
  
  # Make sure that the list is loaded when finding things.
  def test_raise_error_on_not_loaded
    accounts_list = @gateway.get_accounts_list(false)
    assert_equal(false, accounts_list.loaded?)
    assert_raise(XeroGateway::AccountsListNotLoadedError) { accounts_list[200] }
    assert_raise(XeroGateway::AccountsListNotLoadedError) { accounts_list.find_by_code(200) }
    assert_raise(XeroGateway::AccountsListNotLoadedError) { accounts_list.find_all_by_type('EXPENSE') }
    assert_raise(XeroGateway::AccountsListNotLoadedError) { accounts_list.find_all_by_tax_type('OUTPUT') }
  end
  
  # Test simple lookup by account code (from cache).
  def test_simple_lookup_by_account_code
    accounts_list = @gateway.get_accounts_list
    assert_equal(true, accounts_list.loaded?)
    
    # Load data in the stubbed response.
    expected_accounts = accounts_as_array
    
    # Make sure that every single expected account exists in the cached lookup hash.
    expected_accounts.each do | expected_account |
      found_account = accounts_list.find_by_code(expected_account.code)
      assert_kind_of(XeroGateway::Account, found_account)
      assert(expected_account == found_account, "Found account does not match expected account.")

      found_account_shortcut = accounts_list[expected_account.code]
      assert_kind_of(XeroGateway::Account, found_account_shortcut)
      assert(expected_account == found_account_shortcut, "Found account does not match expected account (shortcut).")
    end
  end
  
  # Test finding accounts by their account type (from cache).
  def test_lookup_by_account_type
    accounts_list = @gateway.get_accounts_list
    assert_equal(true, accounts_list.loaded?)
    
    # Load data in the stubbed response.
    expected_accounts = accounts_as_array

    # Get all the unique account types present in the expected accounts data along with their counts.
    unique_types = expected_accounts.inject({}) do | list, account | 
      list[account.type] = 0 if list[account.type].nil?
      list[account.type] += 1
      list
    end
    
    assert_not_equal(0, unique_types)
    unique_types.each do | account_type, count |
      found_accounts = accounts_list.find_all_by_type(account_type)
      assert_equal(count, found_accounts.size)
      found_accounts.each do | found_account | 
        assert_kind_of(XeroGateway::Account, found_account)
        assert_equal(account_type, found_account.type)
      end
    end    
  end

  # Test finding accounts by their tax type (from cache).
  def test_lookup_by_tax_type
    accounts_list = @gateway.get_accounts_list
    assert_equal(true, accounts_list.loaded?)
    
    # Load data in the stubbed response.
    expected_accounts = accounts_as_array

    # Get all the unique tax types present in the expected accounts data along with their counts.
    unique_types = expected_accounts.inject({}) do | list, account | 
      list[account.tax_type] = 0 if list[account.tax_type].nil?
      list[account.tax_type] += 1
      list
    end
    
    assert_not_equal(0, unique_types)
    unique_types.each do | tax_type, count |
      found_accounts = accounts_list.find_all_by_tax_type(tax_type)
      assert_equal(count, found_accounts.size)
      found_accounts.each do | found_account | 
        assert_kind_of(XeroGateway::Account, found_account)
        assert_equal(tax_type, found_account.tax_type)
      end
    end    
  end
  
  private
  
    def accounts_as_array
      response = @gateway.__send__(:parse_response, get_file_as_string("accounts.xml"))
      response.accounts
    end
  
end