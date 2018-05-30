module XeroGateway
  class Report
    class Row
      COLUMN_METHOD_NAME_RE = /^column\_([0-9])+$/

      attr_accessor :section_name

      def initialize(column_titles, columns, section_name = nil)
        @columns                   = columns
        @column_titles             = column_titles
        @column_titles_underscored = column_titles.map(&:to_s).map(&:underscore)
        @section_name              = section_name
      end

      def [](key)
        return @columns[key] if key.is_a?(Integer)

        [ @column_titles, @column_titles_underscored ].each do |names|
          if index = names.index(key.to_s)
            return @columns[index]
          end
        end

        nil
      end

      def method_missing(method_name, *args, &block)
        if method_name =~ COLUMN_METHOD_NAME_RE
          # support column_#{n} style deprecated API
          ActiveSupport::Deprecation.warn("XeroGateway: The #column_n API for accessing report cells will be deprecated in a future version. Please use the underscored column title, a hash or array index accessor", caller_locations)
          @columns[$1.to_i - 1]
        elsif (column_index = @column_titles_underscored.index(method_name.to_s))
          @columns[column_index]
        else
          super
        end
      end

      def respond_to_missing?(method_name, *args)
        (method_name =~ COLUMN_METHOD_NAME_RE) || @column_titles_underscored.include?(method_name.to_s) || super
      end

      def inspect
        "<XeroGateway::Report::Row:#{object_id} #{pairs}>"
      end

      private

        def pairs
          @column_titles.zip(@columns).map do |title, value|
            "#{title.to_s.underscore}: #{value.inspect}"
          end.join(" ")
        end

    end
  end
end