require File.join(File.dirname(__FILE__), '../test_helper.rb')

class LeaveApplication < Test::Unit::TestCase

  should 'be valid' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes).valid?, true)
  end

  should 'be invalid without employee_id' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes.merge({employee_id: nil})).valid?, false)
  end

  should 'be invalid without leave_type_id' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes.merge({leave_type_id: nil})).valid?, false)
  end

  should 'be invalid without title' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes.merge({title: nil})).valid?, false)
  end

  should 'be invalid without start_date' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes.merge({start_date: nil})).valid?, false)
  end

  should 'be invalid without end_date' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes.merge({end_date: nil})).valid?, false)
  end

  should 'be invalid when description more than 200 symbols' do
    assert_equal(XeroGateway::Payroll::LeaveApplication.new(valid_attributes.merge({description: 'a' * 201})).valid?, false)
  end

  def valid_attributes
    {
        employee_id: 1,
        leave_type_id: 2,
        title: 'Title',
        start_date: Time.now,
        end_date: Time.now,
        description: 'Description',
        leave_periods: 'something',
        leave_application_id: 1
    }
  end
end
