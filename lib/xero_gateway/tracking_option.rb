module XeroGateway
  # Tracking Option added to a line item etc
  class TrackingOption < BaseRecord
    attributes(
      'Name' => :string,
      'Option' => :string,
      'TrackingCategoryID' => :string,
      'TrackingOptionID' => :string
    )
    self.element_name = 'TrackingCategory'
  end
end
