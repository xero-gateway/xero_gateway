require File.join(File.dirname(__FILE__), '../test_helper.rb')

class BankAccountTest < Test::Unit::TestCase

  should 'be valid' do
    assert_equal(XeroGateway::Payroll::BankAccount.new.valid?, true)
  end

  should 'be invalid when account_name is more than 32 symbols' do
    assert_equal(XeroGateway::Payroll::BankAccount.new(account_name: 'a' * 33).valid?, false)
  end

  should 'be invalid when statement_text is more than 18 symbols' do
    assert_equal(XeroGateway::Payroll::BankAccount.new(statement_text: 'a' * 19).valid?, false)
  end

  should 'be invalid when bsb is not equal 6 symbols' do
    assert_equal(XeroGateway::Payroll::BankAccount.new(bsb: 'a' * 7).valid?, false)
  end

  should 'be invalid when account_number is more than 9 symbols' do
    assert_equal(XeroGateway::Payroll::BankAccount.new(account_number: 'a' * 10).valid?, false)
  end
end
