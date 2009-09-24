Gem::Specification.new do |s|
  s.name     = "xero_gateway"
  s.version  = "1.0.5"
  s.date     = "2009-09-25"
  s.summary  = "Enables ruby based applications to communicate with the Xero API"
  s.email    = "tlconnor@gmail.com"
  s.homepage = "http://github.com/tlconnor/xero_gateway"
  s.description = "Enables ruby based applications to communicate with the Xero API"
  s.has_rdoc = false
  s.authors  = ["Tim Connor"]
  s.add_dependency('builder', '>= 2.1.2')
  s.files    = ["CHANGELOG.textile",
    "init.rb",
    "LICENSE",
    "Rakefile",
    "README.textile", 
    "lib/xero_gateway.rb",
    "lib/xero_gateway/account.rb",
    "lib/xero_gateway/accounts_list.rb",
    "lib/xero_gateway/address.rb",
    "lib/xero_gateway/ca-certificates.crt",
    "lib/xero_gateway/contact.rb",
    "lib/xero_gateway/dates.rb",
    "lib/xero_gateway/error.rb",
    "lib/xero_gateway/gateway.rb",
    "lib/xero_gateway/http.rb",
    "lib/xero_gateway/http_encoding_helper.rb",
    "lib/xero_gateway/invoice.rb",
    "lib/xero_gateway/line_item.rb",
    "lib/xero_gateway/money.rb",
    "lib/xero_gateway/phone.rb",
    "lib/xero_gateway/payment.rb",
    "lib/xero_gateway/response.rb",
    "lib/xero_gateway/tracking_category.rb",
    "test/test_helper.rb",
    "test/integration/accounts_list_test.rb",
    "test/integration/create_contact_test.rb",
    "test/integration/create_invoice_test.rb",
    "test/integration/get_accounts_test.rb",
    "test/integration/get_contact_test.rb",
    "test/integration/get_contacts_test.rb",
    "test/integration/get_invoice_test.rb",
    "test/integration/get_invoices_test.rb",
    "test/integration/get_tracking_categories_test.rb",
    "test/integration/update_contact_test.rb",
    "test/stub_responses/accounts.xml",
    "test/stub_responses/contact.xml",
    "test/stub_responses/contacts.xml",
    "test/stub_responses/invoice.xml",
    "test/stub_responses/invoices.xml",
    "test/stub_responses/invalid_api_key_error.xml",
    "test/stub_responses/invalid_customer_key_error.xml",
    "test/stub_responses/tracking_categories.xml",
    "test/stub_responses/invoice_not_found_error.xml",
    "test/stub_responses/unknown_error.xml",
    "test/unit/account_test.rb",
    "test/unit/contact_test.rb",
    "test/unit/gateway_test.rb",
    "test/unit/invoice_test.rb",
    "test/unit/tracking_category_test.rb",
    "test/xsd/README",
    "test/xsd/create_contact.xsd",
    "test/xsd/create_invoice.xsd",
    "xero_gateway.gemspec"]
end
