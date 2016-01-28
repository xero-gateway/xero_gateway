module XeroGateway
  class Currency < BaseRecord

    attributes({
      "Code" 	       => :string,     # 3 letter alpha code for the currency – see list of currency codes
      "Description"  => :string, 	   # Name of Currency
    })

  end
end
