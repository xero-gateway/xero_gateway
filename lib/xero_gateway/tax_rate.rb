module XeroGateway
  class TaxRate < BaseRecord
    attributes({
      "Name"                  => :string,
      "TaxType"               => :string,
      "Status"                => :string,
      "CanApplyToAssets"      => :boolean,
      "CanApplyToEquity"      => :boolean,
      "CanApplyToExpenses"    => :boolean,
      "CanApplyToLiabilities" => :boolean,
      "CanApplyToRevenue"     => :boolean,
      "DisplayTaxRate"        => :float,
      "EffectiveRate"         => :float
    })
  end
end
