#
# Contains the class level methods that are inserted into your api class
# when you include the Cleric module.
#
module Cleric
  module Accessors

    # just for example "how to create method in accesors"
    def row name, identifier
      define_method("delete_#{name}") do |value|
        puts "generate delete_#{name} method"
        db[identifier[:table].to_sym].filter(value).delete
      end
    end

    def column name, identifier
      define_method("avg_#{name}") do |value|
        puts "generate avg_#{name} method"
        db[identifier[:table].to_sym].filter(value).avg(identifier.values.last.to_sym)
      end
      define_method("query_#{name}") do |value|
        puts "generate query_#{name} method"
        db[identifier[:table].to_sym].filter(value).map(identifier.values.last.to_sym)
      end
    end

  end
end
