module XeroGateway
  class Account
    
    TYPE = {
      'CURRENT' =>        '',
      'FIXED' =>          '',
      'PREPAYMENT' =>     '',
      'EQUITY' =>         '',
      'DEPRECIATN' =>     '',
      'DIRECTCOSTS' =>    '',
      'EXPENSE' =>        '',
      'OVERHEADS' =>      '',
      'CURRLIAB' =>       '',
      'LIABILITY' =>      '',
      'TERMLIAB' =>       '',
      'OTHERINCOME' =>    '',
      'REVENUE' =>        '',
      'SALES' =>          ''
    } unless defined?(TYPE)
    
    TAX_TYPE = {
      'NONE' =>             'No GST',
      'EXEMPTINPUT' =>      'VAT on expenses exempt from VAT (UK only)',
      'INPUT' =>            'GST on expenses',
      'SRINPUT' =>          'VAT on expenses',
      'ZERORATEDINPUT' =>   'Expense purchased from overseas (UK only)',
      'RRINPUT' =>          'Reduced rate VAT on expenses (UK Only)', 
      'EXEMPTOUTPUT' =>     'VAT on sales exempt from VAT (UK only)',
      'OUTPUT' =>           'OUTPUT',
      'SROUTPUT' =>         'SROUTPUT',
      'ZERORATEDOUTPUT' =>  'Sales made from overseas (UK only)',
      'RROUTPUT' =>         'Reduced rate VAT on sales (UK Only)',
      'ZERORATED' =>        'Zero-rated supplies/sales from overseas (NZ Only)'
    } unless defined?(TAX_TYPE)
    
    attr_accessor :account_id, :code, :name, :type, :tax_type, :description, :system_account, :enable_payments_to_account
    
    def initialize(params = {})
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end
    
    def ==(other)
      [:account_id, :code, :name, :type, :tax_type, :description, :system_account, :enable_payments_to_account].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
    
    def to_xml
      b = Builder::XmlMarkup.new
      
      b.Account {
        b.AccountID self.account_id
        b.Code self.code
        b.Name self.name
        b.Type self.type
        b.TaxType self.tax_type
        b.Description self.description
        b.SystemAccount self.system_account unless self.system_account.nil?
        b.EnablePaymentsToAccount self.enable_payments_to_account
      }
    end
    
    def self.from_xml(account_element)
      account = Account.new
      account_element.children.each do |element|
        case(element.name)
          when "AccountID" then account.account_id = element.text
          when "Code" then account.code = element.text
          when "Name" then account.name = element.text
          when "Type" then account.type = element.text
          when "TaxType" then account.tax_type = element.text
          when "Description" then account.description = element.text
          when "SystemAccount" then account.system_account = element.text
          when "EnablePaymentsToAccount" then account.enable_payments_to_account = (element.text == 'true')
        end
      end      
      account
    end
    
  end
end
