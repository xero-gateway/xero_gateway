require File.dirname(__FILE__) + '/../test_helper'

class GetBrandingThemesTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @gateway = XeroGateway::Gateway.new(CONSUMER_KEY, CONSUMER_SECRET)

    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"

      @gateway.stubs(:http_get).with {|client, url, params| url =~ /BrandingThemes$/i }.returns(get_file_as_string("branding_themes.xml"))
    end
  end

  def test_get_branding_themes
    result = @gateway.get_branding_themes
    assert result.success?
    assert !result.request_params.nil?
    assert !result.response_xml.nil?

    branding_themes = result.branding_themes
    assert_equal 3, branding_themes.size

    branding_theme = branding_themes.first
    assert_kind_of(XeroGateway::BrandingTheme, branding_theme)
    assert_equal "7889a0ac-262a-40e3-8a63-9a769b1a18af", branding_theme.branding_theme_id
    assert_equal "Standard", branding_theme.name
    assert_equal 0, branding_theme.sort_order
    assert_equal Time.utc(2000, 1, 1, 0, 0, 0), branding_theme.created_date_utc
  end
end
