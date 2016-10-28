require 'cleric/accessors'
require 'cleric/yaml'

module Cleric

  def self.included cls
    cls.extend Accessors
  end

end
