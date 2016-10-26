require 'net/ssh/gateway'

module Cleric
  module SSH

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
        ssh.open(host, remote_port, local_port)
      rescue
        fail "fail to forward remote port #{remote_port} to local_port #{local_port}"
      end
    end

    def close_ssh port
      ssh.close port
    end

  end
end
