require 'cleric/accessors'
require 'cleric/ssh'
require 'cleric/db'
require 'cleric/yaml'

module Cleric

  include SSH
  include DB

  attr_accessor :ssh, :port, :db

  def initialize(params ={})
    ssh = params.fetch(:ssh, false)
    db = params.fetch(:db, false)
    @ssh = connect_remote_server ssh if ssh
    @port = forward_port ssh if ssh && db
    @db = connect_database db, @port if db
  end

  def self.included cls
    cls.extend Cleric::Accessors
  end


end
