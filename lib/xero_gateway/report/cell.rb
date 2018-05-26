module XeroGateway
  class Report

    # Adds #attributes to the cells we're grabbing, since Xero Report Cells use XML like:
    # <Cell>
    #   <Value>Interest Income (270)</Value>
    #   <Attributes>
    #     <Attribute>
    #       <Value>e9482110-7245-4a76-bfe2-14500495a076</Value>
    #       <Id>account</Id>
    #     </Attribute>
    #   </Attributes>
    # </Cell>
    #
    # We delegate to the topmost "<Value>" class and decorate with an "attributes" hash
    # for the "attribute: value" pairs
    class Cell < SimpleDelegator
      attr_reader :attributes, :value

      def initialize(value, new_attributes = {})
        @value      = value
        @attributes = new_attributes
        super(value)
      end
    end

  end
end