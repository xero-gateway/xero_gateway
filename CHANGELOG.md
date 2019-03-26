# (v.Next)

# [2.7.0](https://github.com/xero-gateway/xero_gateway/compare/2.6.0...2.7.0)

## Features/Improvements
* Add BrandingTheme setting to Contact records
* Add ability to request list of invoice_ids in get_invoices call (@jumzijie)
* Fix deprecation warnings for BigDecimal use

# [2.6.0](https://github.com/xero-gateway/xero_gateway/compare/2.5.0...2.6.0)

## Deprecations
* Accessing report rows via #column_1 etc will be deprecated,
  please use the column title (e.g `report.rows.first.account`)
  or an array/hash-style accessor (e.g `report.rows.first[0]`
  or `report.rows.first["Account"]`

## Features/Improvements
* Ability to grab Payroll API Pay Runs and Payroll Calendars (thanks @lordmortis)
* Add support for page param when fetching bank transactions
* Populate Invoice#fully_paid_on from FullyPaidOnDate
* Adds the ability to get attributes for Report Cells
* Added the ability to get the section name for a Row by
  calling #section_name on the Row
* Add ContactPerson to Contact XML
* Add DiscountRate to line items

## Bug Fixes
* Fixed a bug where we weren't including all Sections in the
  report object


# [2.5.0](https://github.com/xero-gateway/xero_gateway/compare/2.4.0...2.5.0)

## Features

* Add pagination for invoices
* Ability to provide User-Agent header (required for new Partner app review)
* Allow writing SentToContact status on Invoice

## Bug fixes

* Properly expose `expires_at` on oauth client

