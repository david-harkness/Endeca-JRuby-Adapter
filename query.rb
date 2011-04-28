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
    #puts @eneQuery.methods.sort.inspect
    @eneQuery.setNavNumERecs(perPage);
    @eneQuery.setNavERecsOffset(offset);
    parse_results @eneConn.query(@eneQuery)
  end
  
  private 
    def parse_results(results)
      nav = results.getNavigation()
      recs = nav.getERecs()
      array = []
      hash = {}
      recs.each do |x|
        inner_hash = {}
        x.getProperties.each do |prop|
          inner_hash[prop.shift] = prop.last
          raise 'to much ' if prop.size > 1
        end 
        array << inner_hash        

        x.getDimValues.each do |dv|
        dv.each do |dimloc|
            hash[dimloc.getDimValue.getDimensionName.to_sym] = dimloc.getDimValue.getName
          end
        end
      end

      return {:hash => hash, :array => array}
    end

end

puts "\n" * 3
if ARGV.size != 3
  puts "usage: query.rb XXX.XXX.XXX.XXX XXX  'N=0'"   
  puts "                IP_ADDRESS      PORT 'QUERY'"
  return -1
end

endeca = Endeca.new(ARGV[0], ARGV[1])
hash = endeca.query(ARGV[2], 20, 0)

puts "\e[34m********************* \e[35mFILTERS\e[0m  \e[34m******************\e[0m\n\n"
puts hash[:hash].inspect

hash[:array].each do |x|
  puts "\n\n\e[34m*********************\e[0m \e[35mProperty\e[0m  \e[34m******************\e[0m"
  puts x.inspect
  puts "\e[34m************************************************************************\e[0m\n"
  puts "\nPRESS [\e[32mPRESS ENTER\e[0m] to see next property: \e[33m\e[5m_\e[0m"
  STDOUT.flush
  blah = STDIN.gets
end

puts "\n" *3
#puts hash[:array].inspect
