module XeroGateway
  module LineItemCalculations
    def add_line_item(params = {})
      line_item = nil
      case params
        when Hash then      line_item = LineItem.new(params)
        when LineItem then  line_item = params
        else                raise InvalidLineItemError
      end
      @line_items << line_item
      line_item
    end

    # Deprecated (but API for setter remains).
    #
    # As sub_total must equal SUM(line_item.line_amount) for the API call to pass, this is now
    # automatically calculated in the sub_total method.
    def sub_total=(value)
    end

    # Calculate the sub_total as the SUM(line_item.line_amount).
    def sub_total
      @sub_total || line_items.inject(BigDecimal.new('0')) { | sum, line_item | sum + BigDecimal.new(line_item.line_amount.to_s) }
    end

    # Deprecated (but API for setter remains).
    #
    # As total_tax must equal SUM(line_item.tax_amount) for the API call to pass, this is now
    # automatically calculated in the total_tax method.
    def total_tax=(value)
    end

    # Calculate the total_tax as the SUM(line_item.tax_amount).
    def total_tax
      @total_tax || line_items.inject(BigDecimal.new('0')) { | sum, line_item | sum + BigDecimal.new(line_item.tax_amount.to_s) }
    end

    # Deprecated (but API for setter remains).
    #
    # As total must equal sub_total + total_tax for the API call to pass, this is now
    # automatically calculated in the total method.
    def total=(value)
    end

    # Calculate the toal as sub_total + total_tax.
    def total
      @total || (sub_total + total_tax)
    end

  end
end
