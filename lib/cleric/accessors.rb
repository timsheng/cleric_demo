#
# Contains the class level methods that are inserted into your api class
# when you include the Cleric module.
#
module Cleric
  module Accessors

    # just for example "how to create method in accesors"
    def count_table name
      define_method("#{name}") do
        puts "generate #{name} method "
        db['select id from lead'].count
      end
    end

  end
end
