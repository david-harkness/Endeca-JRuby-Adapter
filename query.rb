#!/usr/bin/env ruby 
require 'java'
require 'endeca_navigation.jar'
java_import 'com.endeca.navigation.ENEQueryResults'
java_import 'com.endeca.navigation.HttpENEConnection'
java_import 'com.endeca.navigation.UrlENEQuery'

class Endeca
  
  def initialize(host, port)
    @eneConn = HttpENEConnection.new(host, port);
  end
  
  def query(url, perPage, offset)
    @eneQuery = UrlENEQuery.new(url, "UTF-8");
    puts @eneQuery.methods.sort.inspect
    @eneQuery.setNavNumERecs(perPage);
    @eneQuery.setNavERecsOffset(offset);
    parse_results @eneConn.query(@eneQuery)
  end
  
  private 
    def parse_results(results)
      nav = results.getNavigation()
      recs = nav.getERecs()
      hash = {}
      recs.each do |x|
        x.getDimValues.each do |dv|
        dv.each do |dimloc|
            hash[dimloc.getDimValue.getDimensionName.to_sym] = dimloc.getDimValue.getName
          end
        end
      end
      return hash
    end

end
if ARGV.size != 3
  puts "usage: query.rb XXX.XXX.XXX.XXX XXX  'N=0'"   
  puts "                IP_ADDRESS      PORT 'QUERY'"
  return -1
end

endeca = Endeca.new(ARGV[0], ARGV[1])
hash = endeca.query(ARGV[2], 20, 0)



puts hash.inspect
