require 'cleric/accessors'

module Cleric
  class DBFactory
    extend Accessors

    attr_accessor :db

    def initialize db
      @db = db
    end

    def query sql
      db[sql].all
    end

    def insert sql
      db[sql]
    end
  end
end
