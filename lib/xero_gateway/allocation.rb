module XeroGateway
  class Allocation < BaseRecord
    attributes(
      'AppliedAmount' => :float,
      'Date' => :date,
      'CreditNoteID' => :string,
      'CreditNoteNumber' => :string,
      'Invoice' => {
        'InvoiceID' => :string,
        'InvoiceNumber' => :string
      }
    )

    alias invoice_id invoice_invoice_id
    alias invoice_number invoice_invoice_number
    alias invoice_id= invoice_invoice_id=
    alias invoice_number= invoice_invoice_number=
  end
end
