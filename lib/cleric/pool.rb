require 'mysql2'
require 'sequel'
require 'net/ssh/gateway'

module Cleric
  class Pool

    attr_accessor :db_pool, :ssh_pool

    def initialize
      @db_pool = {}
      @ssh_pool = {}
    end

    def use(params ={})
      ssh_name = params.fetch(:ssh, false)
      db_name = params.fetch(:db, false)
      if @db_pool[db_name].nil? && db_name
        if @ssh_pool[db_name].nil?
          ssh_key = fetch_ssh_config db_name
          @ssh = connect_remote_server ssh_key
          port = forward_port ssh_key
          @ssh_pool[db_name] = @ssh
        else
          @ssh_pool[db_name]
        end
        @db = connect_database db_name, port
        @db_pool[db_name] = @db
      elsif ssh_name
        @ssh = connect_remote_server ssh_name
        @ssh_pool[ssh_name] = @ssh
      else
        @db_pool[db_name]
      end
    end

    def connect_database name, port=false
      db_conf = Cleric::YAML.fetch_corresponding_conf_by name
      db_conf = db_conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      db_conf = db_conf.merge(:port => port) if port
      # puts "connect #{name} database"
      db = get_ready_for_database db_conf
    end

    def get_ready_for_database conf
      begin
        Sequel.connect(conf)
      rescue
        fail "database configuration \n #{conf} \n is not correct, please double check"
      end
    end

    def connect_remote_server name
      ssh_conf = Cleric::YAML.fetch_corresponding_conf_by name
      ssh_conf = ssh_conf.delete_if { |key,value| key == 'database'}
      # puts "start to connect #{name} remote_server"
      ssh = get_ready_for_ssh ssh_conf
      # puts "connect #{name} remote_server successfully" if ssh.active?
      return ssh
    end

    def get_ready_for_ssh conf
      host = conf.delete('host')
      user = conf.delete('user')
      options = conf.delete_if {|key,value| key == 'host' && 'user'}
      options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      begin
        Net::SSH::Gateway.new(host, user, options)
      rescue
        fail "ssh configuration \n #{conf} \n is not correct, please double check"
      end
    end

    def forward_port name
      ssh_conf = Cleric::YAML.fetch_corresponding_conf_by name
      new_conf = ssh_conf.delete('database')
      host = new_conf.delete('host')
      remote_port = new_conf.delete('remote_port')
      local_port = new_conf.delete('local_port')
      # puts "forward remote port #{remote_port} to local port #{local_port}"
      begin
        @ssh.open(host, remote_port, local_port)
      rescue
        fail "fail to forward remote port #{remote_port} to local_port #{local_port}"
      end
    end

    def fetch_ssh_config db_name
      db_conf = Cleric::YAML.fetch_corresponding_conf_by db_name
      ssh_key = db_conf.delete('ssh')
    end
  end
end
