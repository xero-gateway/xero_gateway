module XeroGateway
  class ContactGroup
    
    # Xero::Gateway associated with this invoice.
    attr_accessor :gateway
    
    # All accessible fields
    attr_accessor :contact_group_id, :name, :status, :contacts
    
    # Boolean representing whether the accounts list has been loaded.
    attr_accessor :contacts_downloaded
    
    def initialize(params = {})
      @contacts = []
      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    # Return the list of Contacts. Will load the contacts if the group
    # hasn't loaded the contacts yet (i.e. returned by a index call)
    #
    # Loaded contacts will only have Name and ContactId set.
    def contacts
      if !@contacts_downloaded && contact_group_id
        @contacts_downloaded = true

        # Load the contact list.
        @contacts = gateway.get_contact_group_by_id(contact_group_id).contact_group.contacts || []
      end

      @contacts
    end

    # Returns the array of ContactIDs. 
    # If the contact_ids array has been assigned, will return that array.
    # Otherwise, returns any loaded ContactIDs
    def contact_ids
      if @contact_ids
        @contact_ids
      else
        contacts.map(&:contact_id)
      end
    end

    # Assign ContactIDs to the group for updating.
    def contact_ids=(contact_ids)
      @contact_ids = contact_ids
    end

    def to_xml(b = Builder::XmlMarkup.new)
      b.ContactGroup {
        b.ContactGroupID contact_group_id unless contact_group_id.nil?
        b.Name self.name
        b.Status self.status

        if @contacts_downloaded || @contact_ids
          b.Contacts {
            self.contact_ids.each do |contact_id|
              b.Contact {
                b.ContactID contact_id
              }
            end
          }
        end
      }
    end

    def self.from_xml(contact_group_element, gateway, options = {})
      contact_group = ContactGroup.new(gateway: gateway, contacts_downloaded: options[:contacts_downloaded])
      contact_group_element.children.each do |element|
        case(element.name)
          when "ContactGroupID" then contact_group.contact_group_id = element.text
          when "Name" then contact_group.name = element.text
          when "Status" then contact_group.status = element.text
          when "Contacts" then
            contact_group.contacts_downloaded = true
            element.children.each do |contact_child|
              contact_group.contacts << Contact.from_xml(contact_child, gateway)
            end
        end
      end
      contact_group              
    end  

  end
end