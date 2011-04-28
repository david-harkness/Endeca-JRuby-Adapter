#!/usr/bin/env ruby 
require 'endeca'

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
