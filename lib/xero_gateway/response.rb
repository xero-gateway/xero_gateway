module XeroGateway
  class Response
    attr_accessor :response_id, :status, :errors, :provider, :date_time, :response_item, :request_params, :request_xml, :response_xml

    def array_wrapped_response_item
      Array(response_item)
    end

    alias_method :invoice,              :response_item
    alias_method :credit_note,          :response_item
    alias_method :bank_transaction,     :response_item
    alias_method :manual_journal,       :response_item
    alias_method :contact,              :response_item
    alias_method :organisation,         :response_item
    alias_method :report,               :response_item
    alias_method :invoices,             :array_wrapped_response_item
    alias_method :credit_notes,         :array_wrapped_response_item
    alias_method :bank_transactions,    :array_wrapped_response_item
    alias_method :manual_journals,      :array_wrapped_response_item
    alias_method :contacts,             :array_wrapped_response_item
    alias_method :accounts,             :array_wrapped_response_item
    alias_method :tracking_categories,  :array_wrapped_response_item
    alias_method :tax_rates,            :array_wrapped_response_item
    alias_method :currencies,           :array_wrapped_response_item
    alias_method :payments,             :array_wrapped_response_item

    def initialize(params = {})
      params.each do |k,v|
        self.send("#{k}=", v)
      end

      @errors ||= []
      @response_item ||= []
    end


    def success?
      status == "OK"
    end

    def error
      errors.blank? ? nil : errors[0]
    end
  end
end
