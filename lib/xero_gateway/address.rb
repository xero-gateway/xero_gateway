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
  class Address
    attr_accessor :address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country
    
    def initialize(params = {})
      params = {
        :address_type => "DEFAULT"
      }.merge(params)
      
      params.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.send("#{k}=", v)
      end
    end
    
    def self.parse(string)
      address = Address.new
      
      string.split("\r\n").each_with_index do |line, index|
        address.instance_variable_set("@line_#{index+1}", line)
      end
      address
    end
    
    def ==(other)
      equal = true
      [:address_type, :line_1, :line_2, :line_3, :line_4, :city, :region, :post_code, :country].each do |field|
        equal &&= (send(field) == other.send(field))
      end
      return equal
    end
  end
end