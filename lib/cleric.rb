require 'ssh_helper'
require 'db_helper'
require 'yaml_helper'

class Cleric

  attr_accessor :ssh, :port, :db

  include Helper::SSH
  include Helper::DB
  include Helper::Yaml

  def initialize ssh_name, mysql_name
    @ssh = connect_remote_server ssh_name
    @port = forward_port ssh_name
    @db = connect_database mysql_name, @port
  end

end
