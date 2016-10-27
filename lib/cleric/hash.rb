require 'builder'

class Hash
  def to_xml
    builder = Builder::XmlMarkup.new
    xml = builder.xml do |b|
      self.each do |tagname, text|
        new_text = (text.is_a?(String) ? "<![CDATA[#{text}]]>" : text.to_s )
        builder.__send__(tagname) do
          builder << new_text
        end
      end
    end
  end
end
