require 'rspec'
require './api/wechat'
require './api/booking'
require './payloads/wechat/wechat_payload'
require 'cleric'
require 'data_magic'

DataMagic.load 'wechat.yml'

class PreDB
  include DataMagic
  def handle
    hash =  data_for('Wechat1')['pre_condition']
    hash.each do |k,v|
      api = Object.const_get(k).new
      if api.respond_to?(v)
        puts api.send v
      else
        puts api.db[v].count
      end
      api.ssh.close(api.port)
    end
  end
end

RSpec.configure do |c|
  c.around(:example) do |example|
    puts "around example before"
    if example.metadata.has_key?(:db)
      pd = PreDB.new
      pd.handle
    end
    example.run
    puts "around example after"
  end
end
