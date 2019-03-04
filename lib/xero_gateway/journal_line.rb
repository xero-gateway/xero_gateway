require File.join(File.dirname(__FILE__), 'account')

module XeroGateway
  class JournalLine
    include Money

    TAX_TYPE = Account::TAX_TYPE unless defined?(TAX_TYPE)

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # All accessible fields
    attr_accessor :journal_line_id, :line_amount, :account_code, :description, :tax_type, :tracking

    def initialize(params = {})
      @errors ||= []
      @tracking ||= []

      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    # Validate the JournalLineItem record according to what will be valid by the gateway.
    #
    # Usage:
    #  journal_line_item.valid?     # Returns true/false
    #
    #  Additionally sets journal_line_item.errors array to an array of field/error.
    def valid?
      @errors = []

      if !journal_line_id.nil? && journal_line_id !~ GUID_REGEX
        @errors << ['journal_line_id', 'must be blank or a valid Xero GUID']
      end

      unless line_amount
        @errors << ['line_amount', "can't be blank"]
      end

      unless account_code
        @errors << ['account_code', "can't be blank"]
      end

      @errors.size == 0
    end

    def has_tracking?
      return false if tracking.nil?

      if tracking.is_a?(Array)
        return tracking.any?
      else
        return tracking.is_a?(TrackingCategory)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.JournalLine {
        b.LineAmount line_amount # mandatory
        b.AccountCode account_code # mandatory
        b.Description description if description # optional
        b.TaxType tax_type if tax_type # optional
        if has_tracking?
          b.Tracking { # optional
            # Due to strange retardness in the Xero API, the XML structure for a tracking category within
            # an invoice is different to a standalone tracking category.
            # This means rather than going category.to_xml we need to call the special category.to_xml_for_invoice_messages
            (tracking.is_a?(TrackingCategory) ? [tracking] : tracking).each do |category|
              category.to_xml_for_invoice_messages(b)
            end
          }
        end
      }
    end

    def self.from_xml(journal_line_element)
      journal_line = JournalLine.new
      journal_line_element.children.each do |element|
        case(element.name)
          when "LineAmount" then journal_line.line_amount = BigDecimal(element.text)
          when "AccountCode" then journal_line.account_code = element.text
          when "JournalLineID" then journal_line.journal_line_id = element.text
          when "Description" then journal_line.description = element.text
          when "TaxType" then journal_line.tax_type = element.text
          when "Tracking" then
            element.children.each do | tracking_element |
              journal_line.tracking << TrackingCategory.from_xml(tracking_element)
            end
        end
      end
      journal_line
    end

    def ==(other)
      [:description, :line_amount, :account_code, :tax_type].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end
  end
end
