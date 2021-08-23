require_relative "game.rb"
Dir.mkdir("saves") unless Dir.exist?("saves")

puts "Welcome to Hangman."
puts "Would you like to start a new game, or continue an old one?"
puts "\t[1]   New Game"
puts "\t[2]   Load Game"
puts "\t[ANY] Quit"
puts
print "Selection: "
input = gets.chomp.strip

case input
when '1'
  Game.new.play
when '2'
  Game.new.play(false)
else
  puts "Goodbye"
end
