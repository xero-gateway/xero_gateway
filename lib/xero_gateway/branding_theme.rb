module XeroGateway
  class BrandingTheme < BaseRecord
    attributes({
      "BrandingThemeID"        => :string,
      "Name" 	                => :string,
      "SortOrder"             => :integer,
      "CreatedDateUTC"        => :string
    })

    def default?
      sort_order == 0
    end
  end
end
