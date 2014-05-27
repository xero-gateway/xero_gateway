module XeroGateway
  class Content

    def initialize(attr_hash)
      attr_hash.each do |k,v|
        add_attr(k, v)
      end
    end

  private

    def add_attr(name, value)
      self.class.send(:attr_accessor, name)
      instance_variable_set("@#{name}", value)
    end

  end
end
