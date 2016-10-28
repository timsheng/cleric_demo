require 'cleric/db'
require 'cleric/ssh'

module Cleric

  class Pool

    attr_accessor :pool

    def initialize
      @pool = {}
    end

    def use db_name, ssh_name = false
      if @pool[db_name].nil?
        ssh = SSH.new
        ssh.connect_remote_server ssh_name if ssh_name
        port = ssh.forward_port ssh_name if ssh_name && db_name
        db = DB.new
        con = db.connect_database db_name, port if db_name
        @pool[db_name] = con
      else
        @pool[db_name]
      end
      return {:db => db, :ssh => ssh, :port => port,:con => @pool[db_name]}
    end
  end
end
