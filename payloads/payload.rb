require 'data_magic'

class Payload

  include DataMagic

  def self.payload key
    DataMagic.load filename
    self.new.data_for(key)['payload']
  end

  def self.filename
    current_class = self.to_s
    array = current_class.split("::")
    path = ''
    array.each do |a|
      a.slice!('Payload') if a.include? 'Payload'
      path = path + a
      path = path + '/' unless a.equal? array.last
    end
    return path.downcase! + '.yml'
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
            v.respond_to?('each') ? prep_data(v) : v
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
