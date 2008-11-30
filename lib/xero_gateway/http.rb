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

module XeroGateway
  module Http
    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 60

    def http_get(url, extra_params = {})
      params = {:apiKey => @api_key, :xeroKey => @customer_key}
      params = params.merge(extra_params).map {|key,value| "#{key}=#{CGI.escape(value.to_s)}"}.join("&")

      uri   = URI.parse(url + "?" + params)

      http = Net::HTTP.new(uri.host, uri.port) 
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT
      http.use_ssl      = true
      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE

      http.get(uri.request_uri).body
    end

    def http_post(url, body, extra_params = {})
      headers = {}
      headers['Content-Type'] ||= "application/x-www-form-urlencoded"      

      params = {:apiKey => @api_key, :xeroKey => @customer_key}
      params = params.merge(extra_params).map {|key,value| "#{key}=#{CGI.escape(value.to_s)}"}.join("&")

      uri   = URI.parse(url + "?" + params)

      http = Net::HTTP.new(uri.host, uri.port) 
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT
      http.use_ssl      = true

      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE

      http.post(uri.request_uri, body, headers).body
    end

    def http_put(url, body, extra_params = {})
      headers = {}
      headers['Content-Type'] ||= "application/x-www-form-urlencoded"      

      params = {:apiKey => @api_key, :xeroKey => @customer_key}
      params = params.merge(extra_params).map {|key,value| "#{key}=#{CGI.escape(value.to_s)}"}.join("&")

      uri   = URI.parse(url + "?" + params)

      http = Net::HTTP.new(uri.host, uri.port) 
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT
      http.use_ssl      = true

      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE

      http.put(uri.request_uri, body, headers).body    
    end      
  end
end