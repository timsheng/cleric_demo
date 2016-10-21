require 'builder'

module Cleric
  module XML
    def to_xml(key, arr = false)
      hash = self.class.payload key
      unless arr == false
        arr.each do |e|
          hash = hash[e]
        end
      end
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
