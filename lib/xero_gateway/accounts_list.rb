module XeroGateway
  class AccountsList
    
    # Xero::Gateway associated with this invoice.
    attr_accessor :gateway
    
    # All accessible fields
    attr_accessor :accounts
    
    # Hash of accounts with the account code as the key.
    attr :accounts_by_code
    
    # Boolean representing whether the accounts list has been loaded.
    attr :loaded
    
    public
    
      def initialize(gateway, initial_load = true)
        raise NoGatewayError unless gateway && gateway.is_a?(XeroGateway::Gateway)
        @gateway = gateway
        @loaded = false
        
        load if initial_load
      end
    
      def load
        @loaded = false
        response = gateway.get_accounts
        @accounts = response.accounts
        @loaded = true
        
        # Cache accounts by code.
        @accounts_by_code = {}
        @accounts.each do | account |
          @accounts_by_code[account.code.to_s] = account
        end
      end
      
      def loaded?
        @loaded == true
      end
      
      # Lookup account by account_code.
      def find_by_code(account_code)
        raise AccountsListNotLoadedError unless loaded?
        @accounts_by_code[account_code.to_s]
      end
      
      # Alias [] method to find_by_code.
      def [](account_code)
        find_by_code(account_code)
      end
    
      # Return a list of all accounts matching account_type.
      def find_all_by_type(account_type)
        raise AccountsListNotLoadedError unless loaded?
        @accounts.inject([]) do | list, account |
          list << account if account.type == account_type
          list
        end
      end
      
      # Return a list of all accounts matching tax_type.
      def find_all_by_tax_type(tax_type)
        raise AccountsListNotLoadedError unless loaded?
        @accounts.inject([]) do | list, account |
          list << account if account.tax_type == tax_type
          list
        end
      end
      
  end
end