require 'builder'
module Cleric
  module XML
    # deperate old to_xml method
    # def to_xml
    #   key = self.instance_variables
    #   key.map! do |k|
    #     k1 = k.to_s.delete! "@"
    #     k1.slice(0,1).capitalize + k1.slice(1..-1)
    #   end
    #   value = self.instance_variables.map do |instance_variable|
    #     self.instance_variable_get(instance_variable)
    #   end
    #   hash = {}
    #   key.zip(value) do |a,b|
    #     hash[a.to_sym] =b
    #   end
    #   builder = Builder::XmlMarkup.new
    #   xml = builder.xml do |b|
    #     hash.each do |tagname, text|
    #       new_text = (text.is_a?(Numeric) ? text : "<![CDATA[#{text}]]>")
    #       builder.__send__(tagname) do
    #         builder << new_text
    #       end
    #     end
    #   end
    # end
    def to_xml
      hash = self.payload
      builder = Builder::XmlMarkup.new
      xml = builder.xml do |b|
        hash.each do |tagname, text|
          new_text = (text.is_a?(String) ? "<![CDATA[#{text}]]>" : text.to_s )
          builder.__send__(tagname) do
            builder << new_text
          end
        end
      end
    end
  end
end
