#!/usr/bin/env ruby

start = Time.now

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'json'

@FRESH = false
@WEEK_SECONDS = 604800

def current_cache?(date)
  tn = Time.now.to_i
  puts tn
  puts date
  
  if (tn - date >= @WEEK_SECONDS)
    puts "Older than a week!"
    return false
  else
    puts "She's a pretty young thing, isn't she?"
    return true
  end
end

def create_cache
  # @TODO create a cache directory for the app
  puts "Making new cache directory..."
end

def read_cache
  # @TODO Use the existing cache file for data store in JSON
end

def make_cache
  # @TODO Do a new request for the new data, delete prev caches, make new cache file
end

# Do we have a cache file yet?
if ( File.directory? (Dir.pwd + '/cache')  ) 
  # We have a cache directory
  
  Dir.foreach(Dir.pwd + '/cache') do |file|
    # We want to skip file references here...
    next if file == '.' or file == '..'
    
    if (  file =~ /^.*.txt$/  )
      puts "Found the file!"
      
      # @TODO Yes, but is it fresh?
      freshest_cache = Dir.glob(Dir.pwd + '/cache/*').max_by {|f| File.mtime(f)}
      
      freshest_cache_basename = File.basename(freshest_cache, ".txt").split("_")
      freshest_cache_timestamp = freshest_cache_basename[1].to_i
      
      if current_cache?(freshest_cache_timestamp)
        puts "Very current."
        # Set a variable to use only the cache, and bail
        @NEED_REFRESH = false
        exit
      else
        puts "Nope, old!"
        # Set a variable to make a new cache file and bail
        @NEED_REFRESH = true
        exit
      end
      

      exit
    else
      puts "File missing."
      # Set a variable to use the new data from the site and bail
      @NEED_REFRESH = true
      exit
    end
  end
else
  # @TODO make the cache directory and bail to getting new data
  create_cache
  exit
end





# Grab unix timestamp
# Get todays timestamp
# Within a week, use the cache file
# Longer than a week, get new data


threads = []

base_url = 'http://www.databasefootball.com/players/playerlist.htm?lt='

player_list_by_letter = Hash.new

alpha =  ("a".."z").to_a
threads = []

alpha.each do |letter|
  
  threads << Thread.new(letter) { |l|
    puts "Fetching all players staring with #{letter}..."
    url = base_url + letter
    players = Array.new
    doc = Nokogiri::HTML(open(url))

    doc.css('table.sortable tbody tr td a').each do |name|
      players << name.content
    end
    
    player_list_by_letter[letter] = players
  }
  
  puts "Results for #{letter} complete."
end

threads.each { |thread| thread.join }

player_list_by_letter = Hash[player_list_by_letter.sort]

# Turn into nicely formated json
player_list_by_letter.to_json


File.open(Dir.pwd + '/cache/players_' + Time.now.to_i.to_s + '.txt', 'w') {|f| f.write(player_list_by_letter)}

finish = Time.new
puts "Task took #{finish - start}"