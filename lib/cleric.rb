require 'cleric/accessors'
require 'cleric/ssh'
require 'cleric/db'
require 'cleric/yaml'

module Cleric

  include SSH
  include DB
  include YAML

  attr_accessor :ssh, :port, :db

  def initialize
    if has_conf_key? self.class
      ssh_name = "#{self.class}_ssh"
      mysql_name = "#{self.class}_db"
      @ssh = connect_remote_server ssh_name
      @port = forward_port ssh_name
      @db = connect_database mysql_name, @port
    else
      puts "no need to initialize db and ssh"
    end
  end

  def self.included cls
    cls.extend Cleric::Accessors
  end

end
