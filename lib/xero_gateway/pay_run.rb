module XeroGateway
  class PayRun  < BaseRecord
    attributes({
      "PayRunID"                => :string,
      "PayrollCalendarID"       => :string,
      "PayRunPeriodStartDate"   => :date,
      "PayRunPeriodEndDate"     => :date,
      "PaymentDate"             => :date,
      "Wages"                   => :currency,
      "Deductions"              => :currency,
      "Tax"                     => :currency,
      "Super"                   => :currency,
      "Reimbursement"           => :currency,
      "NetPay"                  => :currency,
      "PayRunStatus"            => :string,
      "UpdatedDateUTC"          => :datetime_utc
    })
  end
end
