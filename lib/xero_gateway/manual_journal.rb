module XeroGateway
  class ManualJournal
  	include Dates

    GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

    STATUSES = {
      'DRAFT' 	=> 'Draft Manual Journal',
      'POSTED' 	=> 'Posted Manual Journal',
      'DELETED' => 'Deleted Draft Manual Journal',
      'VOIDED'	=> 'Voided Posted Manual Journal'
    } unless defined?(STATUSES)

    # Xero::Gateway associated with this invoice.
    attr_accessor :gateway

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # Represents whether the journal lines have been downloaded when getting from GET /API.XRO/2.0/ManualJournals
    attr_accessor :journal_lines_downloaded

    # accessible fields
    attr_accessor :manual_journal_id, :narration, :date, :status, :journal_lines, :url, :show_on_cash_basis_reports

    def initialize(params = {})
      @errors ||= []
      @payments ||= []

      # Check if the line items have been downloaded.
      @journal_lines_downloaded = (params.delete(:journal_lines_downloaded) == true)

      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @journal_lines ||= []
    end

    def ==(other)
      ['narration', 'status', 'journal_lines', 'show_on_cash_basis_reports'].each do |field|
        return false if send(field) != other.send(field)
      end

      ["date"].each do |field|
        return false if send(field).to_s != other.send(field).to_s
      end
      return true
    end

    # Validate the ManualJournal record according to what will be valid by the gateway.
    #
    # Usage:
    #  manual_journal.valid?     # Returns true/false
    #
    #  Additionally sets manual_journal.errors array to an array of field/error.
    def valid?
      @errors = []

      if !manual_journal_id.nil? && manual_journal_id !~ GUID_REGEX
        @errors << ['manual_journal_id', 'must be blank or a valid Xero GUID']
      end

      if narration.blank?
      	@errors << ['narration', "can't be blank"]
      end

      unless date
        @errors << ['date', "can't be blank"]
      end

      # Make sure all journal_items are valid.
      unless journal_lines.all? { | journal_line | journal_line.valid? }
        @errors << ['journal_lines', "at least one journal line invalid"]
      end

      # make sure there are at least 2 journal lines
      unless journal_lines.length > 1
      	@errors << ['journal_lines', "journal must contain at least two individual journal lines"]
      end

      if journal_lines.length > 100
      	@errors << ['journal_lines', "journal must contain less than one hundred journal lines"]
      end

      unless journal_lines.sum(&:line_amount).to_f == 0.0
      	@errors << ['journal_lines', "the total debits must be equal to total credits"]
      end

      @errors.size == 0
    end


    def journal_lines_downloaded?
      @journal_lines_downloaded
    end

    # If line items are not downloaded, then attempt a download now (if this record was found to begin with).
    def journal_lines
      if journal_lines_downloaded?
        @journal_lines

      elsif manual_journal_id =~ GUID_REGEX && @gateway
        # There is a manual_journal_id so we can assume this record was loaded from Xero.
        # Let's attempt to download the journal_line records (if there is a gateway)

        response = @gateway.get_manual_journal(manual_journal_id)
        raise ManualJournalNotFoundError, "Manual Journal with ID #{manual_journal_id} not found in Xero." unless response.success? && response.manual_journal.is_a?(XeroGateway::ManualJournal)

        @journal_lines = response.manual_journal.journal_lines
        @journal_lines_downloaded = true

        @journal_lines

      # Otherwise, this is a new manual journal, so return the journal_lines reference.
      else
        @journal_lines
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.ManualJournal {
        b.ManualJournalID manual_journal_id if manual_journal_id
        b.Narration narration        
        b.JournalLines {
          self.journal_lines.each do |journal_line|
            journal_line.to_xml(b)
          end
        }
        b.Date ManualJournal.format_date(date || Date.today)
        b.Status status if status
        b.Url url if url
      }
    end

    def self.from_xml(manual_journal_element, gateway = nil, options = {})
      manual_journal = ManualJournal.new(options.merge({:gateway => gateway}))
      manual_journal_element.children.each do |element|
        case(element.name)
          when "ManualJournalID" then manual_journal.manual_journal_id = element.text
          when "Date" then manual_journal.date = parse_date(element.text)
          when "Status" then manual_journal.status = element.text
          when "Narration" then manual_journal.narration = element.text
          when "JournalLines" then element.children.each {|journal_line| manual_journal.journal_lines_downloaded = true; manual_journal.journal_lines << JournalLine.from_xml(journal_line) }
          when "Url" then manual_journal.url = element.text
        end
      end
      manual_journal
    end # from_xml

    def add_journal_line(params = {})
      journal_line = nil
      case params
        when Hash 			 then  journal_line = JournalLine.new(params)
        when JournalLine then  journal_line = params
        else             raise InvalidLineItemError
      end
      @journal_lines << journal_line
      journal_line
    end

  end
end