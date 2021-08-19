require_realative "game.rb"


#setup
# File.open("words.txt", "r") do |all|
#   File.open("longer_words.txt", "w") do |long|
#     line = all.readline
#     until all.eof?
#       long.puts line if line.chomp.strip.length >= 5 && line.chomp.strip.length <= 12
#       line = all.readline
#     end
#   end
# end

# File.open("longer_words.txt", "r") do |long|
#   File.open("no_proper_nouns.txt", "w") do |no_proper|
#     line = long.readline
#     until long.eof?
#       no_proper.puts line if line[0].between?('a','z')
#       line = long.readline
#     end
#   end
# end
