module XeroGateway
  class ContactPerson
    attr_accessor :first_name, :last_name, :email_address, :include_in_emails

    def initialize(params = {})
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.ContactPerson {
        b.FirstName first_name if first_name
        b.LastName last_name if last_name
        b.EmailAddress email_address if email_address
        b.IncludeInEmails include_in_emails if include_in_emails
      }
    end

    def self.from_xml(contact_person_element)
      contact_person = ContactPerson.new
      contact_person_element.children.each do |element|
        case(element.name)
          when "FirstName"       then contact_person.first_name = element.text
          when "LastName"        then contact_person.last_name = element.text
          when "EmailAddress"    then contact_person.email_address = element.text
          when "IncludeInEmails" then contact_person.include_in_emails = (element.text == "true")
        end
      end
      contact_person
    end
  end
end
