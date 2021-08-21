require_relative "game.rb"
Dir.mkdir("saves") unless Dir.exist?("saves")

Game.new.play
