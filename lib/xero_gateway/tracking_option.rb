module XeroGateway
  class TrackingOption < BaseRecord
    attributes(
      'Name' => :string,
      'Option' => :string,
      'TrackingCategoryID' => :string,
      'TrackingOptionID' => :string
    )
    def element_name
      'TrackingCategory'
    end
  end
end
