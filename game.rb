require "pry-byebug"

class Game
  def initialize
  end

  def play(filename = "")
    if filename.empty?
      @word_to_guess = random_word
      @incorrect_guesses_remaining = 8
      @guesses = []
    else
      #file loading stuff
    end

    puts "\n\n"
    display_word_in_progress
    display_guesses
    curr_guess = player_guess
    handle_guess(curr_guess)
    until correct_word_guess?(curr_guess) || all_letters_guessed? ||
          out_of_guesses? || curr_guess == "quit"
      puts "\n\n"
      display_word_in_progress
      display_guesses
      curr_guess = player_guess
      handle_guess(curr_guess)
    end

    if correct_word_guess?(curr_guess)
      puts "You Win! You correctly guessed #{@word_to_guess}!"
    elsif all_letters_guessed?
      puts "You Win! You guessed all of the letters in #{@word_to_guess}!"
    elsif out_of_guesses?
      puts "You Lose! Too many incorrect guesses"
      puts "The correct word was #{@word_to_guess}"
    else
      puts "Thanks for playing Hangman!"
    end
  end

  private

  def save
    filename = file_to_save_to
    if File.open(filename, 'w') do |file|
        YAML.dump(self, file)
      end
    end
  end

  def file_to_save_to
    print "Enter a name to save this game as: "
    input = gets.chomp.strip
    #------------------------------------------------------
  end

  def player_guess
    input = ""
    until input.length == 1 || input.length == @word_to_guess.length ||
          quit_cheat_or_save?(input)
      print "Enter a letter or word to guess or 'quit' to quit: "
      input = gets.chomp.strip.downcase
      if @guesses.include?(input)
        puts "You already guessed '#{input}'"
        next
      end

      unless valid_letter_guess?(input) || valid_word_guess?(input) ||
             quit_cheat_or_save?(input)
        puts "\n\nGuess must be a single letter or the length of the secret word\n\n"
      end
    end
    puts
    input
  end

  def handle_guess(curr_guess)
    if curr_guess == "cheat"
      puts @word_to_guess
      puts
    elsif curr_guess == "save"
      save(name_to_save_as)
    elsif valid_letter_guess?(curr_guess)
      unless correct_letter_guess?(curr_guess)
        @incorrect_guesses_remaining -= 1
      end
      @guesses << curr_guess
    elsif valid_word_guess?(curr_guess)
      unless correct_word_guess?(curr_guess)
        puts "Not the secret word!"
        puts
        @incorrect_guesses_remaining -= 1 unless all_chars_in_guesses?(curr_guess)
      end
    end
  end

  def correct_word_guess?(guess)
    guess == @word_to_guess
  end

  def correct_letter_guess?(guess)
    valid_letter_guess?(guess) && @word_to_guess.include?(guess)
  end

  def valid_letter_guess?(guess)
    guess.length == 1 && guess.downcase.between?("a", "z") &&
      !@guesses.include?(guess)
  end

  def valid_word_guess?(guess)
    guess.length == @word_to_guess.length &&
      all_chars_between?(guess.downcase, "a", "z")
  end

  def quit_cheat_or_save?(input)
    ["quit","cheat","save"].include?(input)
  end

  def all_chars_between?(str, char_a, char_b)
    str.is_a?(String) &&
    str.chars.all? do |char|
      char.between?(char_a, char_b) || char.between?(char_b, char_a)
    end
  end

  def out_of_guesses?
    @incorrect_guesses_remaining == 0
  end

  def all_chars_in_guesses?(guess)
    guess.is_a?(String) &&
    guess.chars.all? do |char|
      @guesses.include?(char)
    end
  end

  def word_in_progress
    word = ""
    @word_to_guess.each_char do |char|
      if @guesses.include?(char)
        word << char
      else
        word << "_"
      end
    end
    word
  end

  def display_word_in_progress
    word = word_in_progress
    puts spread_string(word)
    puts
  end

  def spread_string(str)
    out = ""
    str.each_char { |char| out << "#{char} " }
    out
  end

  def display_guesses
    guesses_str = spread_string(@guesses.join(""))
    puts "Guesses: #{guesses_str}"
    puts
    puts "Incorrect guesses remaining: #{@incorrect_guesses_remaining}"
    puts
  end

  def all_letters_guessed?
    @word_to_guess.chars.all? { |char| @guesses.include?(char) }
  end

  def random_word
    File.open("words.txt") do |file|
      words = file.readlines(chomp: true)
      words[rand(words.length)].strip
    end
  end
end
