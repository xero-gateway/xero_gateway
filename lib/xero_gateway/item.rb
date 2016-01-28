module XeroGateway
  class Item < BaseRecord
    attributes({
        "Code"          => :string,
        "InventoryAssetAccountCode" => :string,
        "Name"          => :string,
        "IsSold"        => :boolean,
        "IsPurchased"   => :boolean,
        "Description"   => :string,
        "PurchaseDescription" => :string,
        "IsTrackedAsInventory" => :boolean,
        "TotalCostPool" => :float,
        "QuantityOnHand" => :integer,

        "SalesDetails"  => {
          "UnitPrice"     => :float,
          "AccountCode"   => :string
        },

        "PurchaseDetails" => {
          "UnitPrice"     => :float,
          "AccountCode"   => :string
        }
    })
  end
end
