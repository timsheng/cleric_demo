require 'net/ssh/gateway'

module Cleric
  module SSH

    def connect_remote_server name
      puts "start to connect #{name} remote_server"
      conf_value = fetch_corresponding_configure_value name
      conf_value = conf_value.delete_if { |key,value| key == :database.to_s}
      begin
        ssh = get_ready_for_ssh conf_value
        puts "connect #{name} remote_server successfully" if ssh.active?
      rescue
        puts "fail to connect remote_server"
      end
      ssh
    end

    def get_ready_for_ssh conf
      conf = conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      host = conf.delete(:host)
      user = conf.delete(:user)
      options = conf.delete_if {|key,value| key == :host && :user}
      Net::SSH::Gateway.new(host, user, options)
    end

    def forward_port name
      puts "forward remote port to local port"
      conf_value = fetch_corresponding_configure_value name
      conf_value = conf_value.delete(:database.to_s)
      conf_value = conf_value.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      host = conf_value.delete(:host)
      remote_port = conf_value.delete(:remote_port)
      local_port = conf_value.delete(:local_port)
      ssh.open(host, remote_port, local_port)
    end

  end
end
