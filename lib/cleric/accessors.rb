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

    def delete_query name, identifier
      puts identifier.keys.last
      define_method("#{name}") do
        puts "generate #{name} method "
        db.execute("delete from #{identifier[:db]} where #{identifier.keys.last} = '#{identifier.values.last}'")
      end
    end

    def query name, identifier
      define_method("#{name}") do
        puts "generate #{name} method "
        properties = db[identifier[:db].to_sym]
        properties.filter(identifier.keys.last => identifier.values.last).map(name).first
      end
    end

  end
end
