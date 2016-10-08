require 'data_magic'

class Payload

  include DataMagic

  attr_accessor :payload

  def initialize key
    DataMagic.load filename
    @payload = data_for(key)['payload']
  end

  private

  def filename
    current_class = self.class.to_s
    current_class.slice! "Payload"
    file_name = current_class.downcase!
    return file_name + '.yml'
  end

end


module DataMagic
  private

  def prep_data(data)
    data.each do |key, value|
      unless value.nil?
        next if !value.respond_to?('[]') || value.is_a?(Numeric)
        if value.is_a?(Hash)
          prep_data(value)
        elsif value.is_a?(Array)
          value.each do |v|
            prep_data(v)
          end
        else
          data[key] = translate(value[1..-1]) if value[0,1] == "~"
          data[key] = transform(value[1..-1]) if value[0,1] == "^"
        end
      end
    end
    data
  end

  def transform(value)
    self.send :eval, value
  end

end
