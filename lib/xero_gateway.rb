# Copyright (c) 2008 Tim Connor <tlconnor@gmail.com>
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require 'cgi'
require "uri"
require 'net/https'
require "rexml/document"
require "builder"
require "bigdecimal"

require File.dirname(__FILE__) + "/xero_gateway/http"
require File.dirname(__FILE__) + "/xero_gateway/dates"
require File.dirname(__FILE__) + "/xero_gateway/money"
require File.dirname(__FILE__) + "/xero_gateway/response"
require File.dirname(__FILE__) + "/xero_gateway/line_item"
require File.dirname(__FILE__) + "/xero_gateway/invoice"
require File.dirname(__FILE__) + "/xero_gateway/contact"
require File.dirname(__FILE__) + "/xero_gateway/address"
require File.dirname(__FILE__) + "/xero_gateway/phone"
require File.dirname(__FILE__) + "/xero_gateway/messages/contact_message"
require File.dirname(__FILE__) + "/xero_gateway/messages/invoice_message"
require File.dirname(__FILE__) + "/xero_gateway/gateway"
