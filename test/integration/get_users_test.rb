require File.dirname(__FILE__) + '/../test_helper'

class GetUsersTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Employees$/ }.returns(get_file_as_string("users.xml"))
      @gateway.stubs(:http_put).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("users.xml"))
      @gateway.stubs(:http_post).with {|client, url, body, params| url =~ /Employees$/ }.returns(get_file_as_string("users.xml"))
    end
  end

  def test_get_users
    # Make sure there is an employee in Xero to retrieve
    user = @gateway.create_user(dummy_user).user
    flunk "get_users could not be tested because create_user failed" if user.nil?

    result = @gateway.get_users
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?
    assert result.users.collect {|e| e.employee_id}.include?(user.employee_id)
  end

  # Make sure that a reference to gateway is passed when the get_employees response is parsed.
  def test_get_users_gateway_reference
    result = @gateway.get_users
    assert(result.success?)
    assert_not_equal(0, result.users.size)

    result.users.each do | user |
      assert(users.gateway === @gateway)
    end
  end

end