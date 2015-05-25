require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class HomeAddressTest < Test::Unit::TestCase
  context 'valid?' do
    context 'postal_code' do
      context 'postal_code is blank' do
        setup do
          @home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add1', city: 'city', region: 'NT')
        end

        should 'return errors' do
          assert_equal @home_address.valid?, false
          assert_equal @home_address.errors, [['postal_code', 'cannot be blank']]
        end
      end

      context 'postal_code is present' do
        context 'postal_code is not in the correct format' do
          setup do
            @home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add1', city: 'city', region: 'NT', postal_code: 'code')
          end

          should 'return errors' do
            assert_equal @home_address.valid?, false
            assert_equal @home_address.errors, [['postal_code', 'must contain exactly 4 digits']]
          end
        end

        context 'postal_code is in the correct format' do
          setup do
            @home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add1', city: 'city', region: 'NT', postal_code: '1234')
          end

          should 'be valid' do
            assert_equal @home_address.valid?, true
            assert_equal @home_address.errors, []
          end
        end
      end
    end

    context 'region' do
      context 'region is blank' do
        setup do
          @home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add1', city: 'city', postal_code: '1234')
        end

        should 'return errors' do
          assert_equal @home_address.valid?, false
          assert_equal @home_address.errors, [['region', "cannot be blank"]]
        end
      end

      context 'region is present' do
        context 'region has invalid abbreviation' do
          setup do
            @home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add1', city: 'city', postal_code: '1234', region: '12')
          end

          should 'return errors' do
            assert_equal @home_address.valid?, false
            assert_equal @home_address.errors, [['region', "must have a valid state abbreviation"]]
          end
        end

        context 'region has valid abbreviation' do
          setup do
            @home_address = XeroGateway::Payroll::HomeAddress.new(address_line1: 'add1', city: 'city', postal_code: '1234', region: 'NT')
          end

          should 'be valid' do
            assert_equal @home_address.valid?, true
            assert_equal @home_address.errors, []
          end
        end
      end
    end
  end
end