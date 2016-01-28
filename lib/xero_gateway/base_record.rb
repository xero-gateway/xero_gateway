module XeroGateway
  class BaseRecord
    class_attribute :element_name
    class_attribute :attribute_definitions

    class << self
      def attributes(hash)
        hash.each do |k, v|
          attribute k, v
        end
      end

      def attribute(name, value)
        self.attribute_definitions ||= {}
        self.attribute_definitions[name] = value

        case value
        when Hash
          value.each do |k, v|
            attribute("#{name}#{k}", v)
          end
        else
          attr_accessor name.underscore
        end
      end

      def from_xml(base_element)
        new.from_xml(base_element)
      end

      def xml_element
        element_name || self.name.split('::').last
      end
    end

    def initialize(params = {})
      params.each do |k,v|
        self.send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    def ==(other)
      to_xml == other.to_xml
    end

    def to_xml
      builder = Builder::XmlMarkup.new
      builder.__send__(self.class.xml_element) do
        to_xml_attributes(builder)
      end
    end

    def from_xml(base_element)
      from_xml_attributes(base_element)
      self
    end

    def from_xml_attributes(element, attribute = nil, attr_definition = self.class.attribute_definitions)
      if Hash === attr_definition
        element.children.each do |child|
          next unless child.respond_to?(:name)
          
          child_attribute = child.name
          child_attr_definition = attr_definition[child_attribute]
          next unless child_attr_definition

          from_xml_attributes(child, "#{attribute}#{child_attribute}", child_attr_definition)
        end

        return
      end

      value = case attr_definition
        when :boolean then  element.text == "true"
        when :float   then  element.text.to_f
        when :integer then  element.text.to_i
        else                element.text
      end if element.text.present?

      send("#{attribute.underscore}=", value)
    end

    def to_xml_attributes(builder = Builder::XmlMarkup.new, path = nil, attr_definitions = self.class.attribute_definitions)
      attr_definitions.each do |attr, value|
        case value
        when Hash
          builder.__send__(attr) do
            to_xml_attributes(builder, "#{path}#{attr}", value)
          end
        else
          builder.__send__(attr, send("#{path}#{attr}".underscore))
        end
      end
    end

  end
end
