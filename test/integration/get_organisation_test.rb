require File.dirname(__FILE__) + '/../test_helper'

class GetOrganisationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Organisation$/ }.returns(get_file_as_string("organisation.xml"))
    end
  end

  def test_get_organisation
    result = @gateway.get_organisation
    assert result.success?
    assert !result.response_xml.nil?

    assert_equal XeroGateway::Organisation, result.organisation.class
    assert_equal "Demo Company (NZ)", result.organisation.name
    assert_equal "c3d5e782-2153-4cda-bdb4-cec791ceb90d", result.organisation.organisation_id
  end
end
