require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class EmployeeTest < Test::Unit::TestCase
  context 'status' do
    setup do
      @employee = XeroGateway::Payroll::Employee.new(date_of_birth: 20.years.ago, employee_id: "54169dad-60ba-436d-9533-3fdbcec0be97", job_title: 'dev')
      @employee.home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add', region: 'ACT', postal_code: '1234', city: 'city')
    end

    context 'status is found' do
      setup do
        @employee.status = 'ACTIVE'
      end

      should 'assign status to employee' do
        assert_equal @employee.status, 'ACTIVE'
      end

      should 'not add errors' do
        assert_equal @employee.valid?, true
        assert_equal @employee.errors, []
      end
    end

    context 'status is not found' do
      setup do
        @employee.status = 'PASSIVE'
      end

      should 'add errors' do
        assert_equal @employee.valid?, false
        assert_equal @employee.errors, [["status", "must be one of ACTIVE/DELETED"]]
      end
    end
  end

  context 'check valid?' do
    setup do
      @home = XeroGateway::Payroll::HomeAddress.new(region: 'ACT', postal_code: '1234', city: 'city')
      @employee = XeroGateway::Payroll::Employee.new(employee_id: "54169dad-60ba-436d-9533-3fdbcec0be97", job_title: 'dev', status: 'ACTIVE')
      @employee.home_address = @home
    end

    context 'date_of_birth' do
      setup do
        @home.stubs(:valid?).returns(true)
      end

      context 'date_of_birth not present' do
        should 'return error' do
          assert_equal @employee.valid?, false
          assert_equal @employee.errors, [["Date of Birth", "cannot be blank"]]
        end
      end

      context 'date_of_birth present' do
        context 'date_of_birth is not in the past' do
          setup { @employee.date_of_birth = Date.today }

          should 'return error' do
            assert_equal @employee.valid?, false
            assert_equal @employee.errors, [["Date of Birth", "must be in the past"]]
          end
        end

        context 'date_of_birth is in the past' do
          setup { @employee.date_of_birth = 20.years.ago }

          should 'return no error' do
            assert_equal @employee.valid?, true
            assert_equal @employee.errors, []
          end
        end
      end
    end

    context 'home address' do
      context 'not valid' do
        setup do
          @employee.date_of_birth = 20.years.ago
        end

        should 'add up error' do
          assert_equal @employee.valid?, false
          assert_equal @employee.errors, [["address_line1", "cannot be blank"]]
        end
      end

      context 'valid' do
        setup do
          @employee.date_of_birth = 20.years.ago
          @home.address_line1 = 'address'
        end

        should 'not add up errors' do
          assert_equal @employee.valid?, true
          assert_equal @employee.errors, []
        end
      end
    end
  end
end
