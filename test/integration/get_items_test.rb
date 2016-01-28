require File.dirname(__FILE__) + '/../test_helper'

class GetItemsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /Items$/ }.returns(get_file_as_string("items.xml"))
    end
  end

  def test_get_items
    result = @gateway.get_items
    assert result.success?
    assert !result.response_xml.nil?

    assert result.items.size > 0
    assert_equal XeroGateway::Item, result.items.first.class
    assert_equal "An Untracked Item", result.items.first.name
  end
end
