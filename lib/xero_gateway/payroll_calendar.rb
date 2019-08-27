module XeroGateway
  class PayrollCalendar  < BaseRecord
    attributes({
      "PayrollCalendarID"     => :string,
      "Name"                  => :string,
      "CalendarType"          => :string,
      "StartDate"             => :date,
      "PaymentDate"           => :date,
      "UpdatedDateUTC"        => :datetime_utc
    })
  end
end
