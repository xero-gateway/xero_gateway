Xero API wrapper [![Build Status](https://travis-ci.org/xero-gateway/xero_gateway.svg?branch=master)](https://travis-ci.org/xero-gateway/xero_gateway) [![Gem Version](https://badge.fury.io/rb/xero_gateway.svg)](https://badge.fury.io/rb/xero_gateway)
================

Introduction
------------

This library is designed to help ruby / rails based applications
communicate with the publicly available API for Xero. If you are
unfamiliar with the API, you should first read the documentation,
located here <http://blog.xero.com/developer/>

Usage
-----

        require 'xero_gateway'
        gateway = XeroGateway::Gateway.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)

Authenticating with OAuth
-------------------------

OAuth is built into this library in a very similar manner to the Twitter
gem by John Nunemaker
([http://github.com/jnunemaker/twitter](http://github.com/jnunemaker/twitter)).
So if you've used that before this will all seem familiar.

### Consumer Key & Secret

First off, you'll need to get a Consumer Key/Secret pair for your
application from Xero.\
Head to <http://api.xero.com>, log in and then click My Applications
&gt; Add Application.

If you want to create a private application (that accesses your own Xero
account rather than your users), you'll need to generate an RSA keypair
and an X509 certificate. This can be done with OpenSSL as below:

        openssl genrsa –out privatekey.pem 1024
        openssl req –newkey rsa:1024 –x509 –key privatekey.pem –out publickey.cer –days 365
        openssl pkcs12 –export –out public_privatekey.pfx –inkey privatekey.pem –in publickey.cer

On the right-hand-side of your application's page there's a box titled
"OAuth Credentials". Use the Key and Secret from this box in order to
set up a new Gateway instance.

(If you're unsure about the Callback URL, specify nothing - it will
become clear a bit later)

### Xero Gateway Initialization

        require 'xero_gateway'
        gateway = XeroGateway::Gateway.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)

or for private applications

        require 'xero_gateway'
        gateway = XeroGateway::PrivateApp.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET, PATH_TO_YOUR_PRIVATE_KEY)

### Request Token

You'll then need to get a Request Token from Xero.

        request_token = gateway.request_token

You should keep this around - you'll need it to exchange for an Access
Token later. (If you're using Rails, this means storing it in the
session or something similar)

Next, you need to redirect your user to the authorisation url for this
request token. In Rails, that looks something like this:

        redirect_to request_token.authorize_url

You may also provide a callback parameter, which is the URL within your
app the user will be redirected to. See next section for more
information on what parameters Xero sends with this request.

        redirect_to request_token(:oauth_callback => "http://www.something.com/xero/complete").authorize_url

### Retrieving an Access Token

If you've specified a Callback URL when setting up your application or
provided an oauth\_callback parameter on your request token, your user
will be redirected to that URL with an OAuth Verifier as a GET
parameter. You can then exchange your Request Token for an Access Token
like this (assuming Rails, once again):

        gateway.authorize_from_request(request_token.token, request_token.secret, :oauth_verifier => params[:oauth_verifier])

(If you haven't specified a Callback URL, the user will be presented
with a numeric verifier which they must copy+paste into your
application; see examples/oauth.rb for an example)

Now you can access Xero API methods:

        gateway.get_contacts

### Storing Access Tokens

You can also store the Access Token/Secret pair so that you can access
the API without user intervention. Currently, these access tokens are
only valid for 30 minutes, and will raise a
XeroGateway::OAuth::TokenExpired exception if you attempt to access the
API beyond the token's expiry time.

        access_token, access_secret = gateway.access_token

### Examples

Open examples/oauth.rb and change CONSUMER\_KEY and CONSUMER\_SECRET to
the values for a Test OAuth Application in order to see an example of
OAuth at work.

If you're working with Rails, a controller similar to this might come in
handy:


      class XeroSessionsController < ApplicationController

        before_filter :get_xero_gateway

        def new
          session[:request_token]  = @xero_gateway.request_token.token
          session[:request_secret] = @xero_gateway.request_token.secret

          redirect_to @xero_gateway.request_token.authorize_url
        end

        def create
          @xero_gateway.authorize_from_request(session[:request_token], session[:request_secret],
                                               :oauth_verifier => params[:oauth_verifier])

          session[:xero_auth] = { :access_token  => @xero_gateway.access_token.token,
                                  :access_secret => @xero_gateway.access_token.secret }

          session.data.delete(:request_token); session.data.delete(:request_secret)
        end

        def destroy
          session.data.delete(:xero_auth)
        end

        private

          def get_xero_gateway
            @xero_gateway = XeroGateway::Gateway.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)
          end

      end

Note that I'm just storing the Access Token + Secret in the session here
- you could equally store them in the database if you felt like
refreshing them every 30 minutes ;)

Implemented interface methods
-----------------------------

### GET /api.xro/2.0/contact (get\_contact\_by\_id)

Gets a contact record for a specific Xero organisation

        result = gateway.get_contact_by_id(contact_id)
        contact = result.contact if result.success?

### GET /api.xro/2.0/contact (get\_contact\_by\_number)

Gets a contact record for a specific Xero organisation

        gateway.get_contact_by_number(contact_number)

### GET /api.xro/2.0/contacts (get\_contacts)

Gets all contact records for a particular Xero customer.

        gateway.get_contacts(:type => :all, :sort => :name, :direction => :desc)
        gateway.get_contacts(:type => :all, :modified_since => 1.month.ago) # modified since 1 month ago

### PUT /api.xro/2.0/contact

Saves a contact record for a particular Xero customer.

        contact = gateway.build_contact
        contact.name = "The contacts name"
        contact.email = "whoever@something.com"
        contact.phone.number = "555 123 4567"
        contact.address.line_1 = "LINE 1 OF THE ADDRESS"
        contact.address.line_2 = "LINE 2 OF THE ADDRESS"
        contact.address.city = "WELLINGTON"
        contact.address.region = "WELLINGTON"
        contact.address.country = "NEW ZEALAND"
        contact.address.post_code = "6021"

        contact.save

### POST /api.xro/2.0/contact

Updates an existing contact record.

        contact_retrieved_from_xero.email = "something_new@something.com"
        contact_retrieved_from_xero.save

### POST /api.xro/2.0/contacts

Creates a list of contacts or updates them if they have a matching
contact\_id, contact\_number or name.\
This method uses only a single API request to create/update multiple
contacts.

        contacts = [XeroGateway::Contact.new(:name => 'Joe Bloggs'), XeroGateway::Contact.new(:name => 'Jane Doe')]
        result = gateway.update_contacts(contacts)

### GET /api.xro/2.0/invoice (get\_invoice)

Gets an invoice record for a specific Xero organisation by either id or
number

        gateway.get_invoice(invoice_id_or_number)

### GET /api.xro/2.0/invoices (get\_invoices)

Gets all invoice records for a particular Xero customer.

        gateway.get_invoices
        gateway.get_invoices(:modified_since => 1.month.ago) # modified since 1 month ago

### PUT /api.xro/2.0/invoice

Inserts an invoice for a specific organization in Xero (Currently only
adding new invoices is allowed).

Invoice and line item totals are calculated automatically.

        invoice = gateway.build_invoice({
          :invoice_type => "ACCREC",
          :due_date => 1.month.from_now,
          :invoice_number => "YOUR INVOICE NUMBER",
          :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
          :line_amount_types => "Inclusive" # "Inclusive", "Exclusive" or "NoTax"
        })
        invoice.contact.name = "THE NAME OF THE CONTACT"
        invoice.contact.phone.number = "12345"
        invoice.contact.address.line_1 = "LINE 1 OF THE ADDRESS"

        line_item = XeroGateway::LineItem.new(
          :description => "THE DESCRIPTION OF THE LINE ITEM",
          :account_code => 200,
          :unit_amount => 1000
        )

        line_item.tracking << XeroGateway::TrackingCategory.new(:name => "tracking category", :options => "tracking option")

        invoice.line_items << line_item

            invoice.create

### POST /api.xro/2.0/invoice

Updates an existing invoice record.

        invoice_retrieved_from_xero.due_date = Date.today
        invoice_retrieved_from_xero.save

### PUT /api.xro/2.0/invoices

Inserts multiple invoices for a specific organization in Xero (currently
only adding new invoices is allowed).\
This method uses only a single API request to create/update multiple
contacts.

        invoices = [XeroGateway::Invoice.new(...), XeroGateway::Invoice.new(...)]
        result = gateway.create_invoices(invoices)

### GET /api.xro/2.0/credit\_note (get\_credit\_note\_by\_id)

Gets an credit\_note record for a specific Xero organisation

        gateway.get_credit_note_by_id(credit_note_id)

### GET /api.xro/2.0/credit\_note (get\_credit\_note\_by\_number)

Gets a credit note record for a specific Xero organisation

        gateway.get_credit_note_by_number(credit_note_number)

### GET /api.xro/2.0/credit\_notes (get\_credit\_notes)

Gets all credit note records for a particular Xero customer.

        gateway.get_credit_notes
        gateway.get_credit_notes(:modified_since => 1.month.ago) # modified since 1 month ago

### PUT /api.xro/2.0/credit\_note

Inserts a credit note for a specific organization in Xero (Currently
only adding new credit notes is allowed).

CreditNote and line item totals are calculated automatically.

        credit_note = gateway.build_credit_note({
          :credit_note_type => "ACCRECCREDIT",
          :credit_note_number => "YOUR CREDIT NOTE NUMBER",
          :reference => "YOUR REFERENCE (NOT NECESSARILY UNIQUE!)",
          :line_amount_types => "Inclusive" # "Inclusive", "Exclusive" or "NoTax"
        })
        credit_note.contact.name = "THE NAME OF THE CONTACT"
        credit_note.contact.phone.number = "12345"
        credit_note.contact.address.line_1 = "LINE 1 OF THE ADDRESS"    
        credit_note.add_line_item({
          :description => "THE DESCRIPTION OF THE LINE ITEM",
          :unit_amount => 1000,
          :tax_amount => 125,
          :tracking_category => "THE TRACKING CATEGORY FOR THE LINE ITEM",
          :tracking_option => "THE TRACKING OPTION FOR THE LINE ITEM"
        })

            credit_note.create

### PUT /api.xro/2.0/credit\_notes

Inserts multiple credit notes for a specific organization in Xero
(currently only adding new credit notes is allowed).\
This method uses only a single API request to create/update multiple
contacts.

        credit_notes = [XeroGateway::CreditNote.new(...), XeroGateway::CreditNote.new(...)]
        result = gateway.create_credit_notes(credit_notes)

### GET /api.xro/2.0/accounts

Gets all accounts for a specific organization in Xero.

        gateway.get_accounts

For more advanced (and cached) access to the accounts list, use the
following.

        accounts_list = gateway.get_accounts_list

Finds account with code of '200'

        sales_account = accounts_list.find_by_code(200)

Finds all EXPENSE accounts. For a list of valid account types see
<code>XeroGateway::Account::TYPE</code>

       all_expense_accounts = accounts_list.find_all_by_type('EXPENSE')

Finds all accounts with tax\_type == 'OUTPUT'. For a list of valid tax
types see <code>XeroGateway::Account::TAX\_TYPE</code>

       all_output_tax_accounts = accounts_list.find_all_by_tax_type('OUTPUT')

### GET /api.xro/2.0/tracking

Gets all tracking categories and their options for a specific
organization in Xero.

        gateway.get_tracking_categories

### GET /api.xero/2.0/Organisation

Retrieves organisation details for the authorised application.

        gateway.get_organisation.organisation

### GET /api.xero/2.0/Currencies

Retrieves currencies in use for the authorised application.

        gateway.get_currencies.currencies

### GET /api.xero/2.0/TaxRates

Retrieves Tax Rates in use for the authorised application.

        gateway.get_tax_rates.tax_rates

Logging
-------

You can specify a logger to use (so you can track down those tricky
exceptions) by using:

      gateway.logger = ActiveSupport::BufferedLogger.new("log_file_name.log")

It doesn't have to be a buffered logger - anything that responds to
"info" will do just fine.
