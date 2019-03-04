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

    %w(sub_total total_tax total).each do |line_item_total_type|
      define_method("#{line_item_total_type}=") do |new_total|
        instance_variable_set("@#{line_item_total_type}", new_total) unless line_items_downloaded?
      end
    end

    # Calculate the sub_total as the SUM(line_item.line_amount).
    def sub_total
      total_cache(:sub_total) || sum_line_items(line_items, :line_amount)
    end

    # Calculate the total_tax as the SUM(line_item.tax_amount).
    def total_tax
      total_cache(:total_tax) || sum_line_items(line_items, :tax_amount)
    end

    # Calculate the toal as sub_total + total_tax.
    def total
      total_cache(:total) || (sub_total + total_tax)
    end

    private

      def total_cache(name)
        instance_variable_defined?("@#{name}") && instance_variable_get("@#{name}")
      end

      def sum_line_items(lines, sum_type = :line_amount)
        lines.inject(BigDecimal('0')) do |sum, line|
          sum + BigDecimal(line.send(sum_type).to_s)
        end
      end

  end
end
