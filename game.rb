require "yaml"

class Game
  attr_reader :word_to_guess, :guesses, :incorrect_guesses_remaining

  def initialize
    @end_game = false
  end

  def play(new_game = true)
    if new_game
      new_game_setup
    else
      unless display_load_menu
        new_game_setup
      end
    end

    curr_guess = prompt_and_process_guess
    until correct_word_guess?(curr_guess) || all_letters_guessed? ||
          out_of_guesses? || curr_guess == "quit" || @end_game
      curr_guess = prompt_and_process_guess
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

  def all_chars_between?(str, char_a, char_b)
    str.is_a?(String) &&
    str.chars.all? do |char|
      char.between?(char_a, char_b) || char.between?(char_b, char_a)
    end
  end

  def all_chars_in_guesses?(guess)
    guess.is_a?(String) &&
    guess.chars.all? do |char|
      @guesses.include?(char)
    end
  end

  def all_letters_guessed?
    @word_to_guess.chars.all? { |char| @guesses.include?(char) }
  end

  def correct_letter_guess?(guess)
    valid_letter_guess?(guess) && @word_to_guess.include?(guess)
  end

  def correct_word_guess?(guess)
    guess == @word_to_guess
  end

  def display_guesses
    guesses_str = spread_string(@guesses.join(""))
    puts "Guesses: #{guesses_str}"
    puts
    puts "Incorrect guesses remaining: #{@incorrect_guesses_remaining}"
    puts
  end

  def display_load_menu
    paths = Dir.glob("saves/*.yaml").sort
    if paths.length > 0
      file_number = 1
      paths.each do |path|
        print "[#{file_number}] "
        display_save_game_info(path)
        puts "\n\n"
        file_number += 1
      end
      print "Select the number [x] of the file you want to load (ex: '1'): "
      input = gets.chomp.strip
      until load_file_number_valid(input, paths)
        print "Selection must be a number listed: "
        input = gets.chomp.strip
      end
      return load_game(paths[input.to_i - 1])
    else
      puts "No games to load\n\n"
      false
    end
  end

  def display_save_game_info(path)
    if File.exist?(path)
      data = YAML.load_file(path)
      word = data.word_to_guess
      incorrect_rem = data.incorrect_guesses_remaining
      guesses = data.guesses
      puts path_to_save_name(path)
      puts spread_string(word_in_progress(word, guesses))
      puts "Guesses: #{spread_string(guesses.join(""))}"
      puts "Incorrect guesses remaining: #{incorrect_rem}"
    else
      puts "Could not find '#{path}'"
    end
  end

  def display_word_in_progress(word_to_guess, guesses)
    word = word_in_progress(word_to_guess, guesses)
    puts spread_string(word)
    puts
  end

  def handle_guess(curr_guess)
    if curr_guess == "cheat"
      puts @word_to_guess
      puts
    elsif curr_guess == "save"
      save
      quit
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

  def load_file_number_valid(input, paths)
    input && input.length != 0 && input.to_i > 0 && input.to_i < paths.length + 1
  end

  def load_game(path)
    if File.exist?(path)
      data = YAML.load_file(path)
      @word_to_guess = data.word_to_guess
      @incorrect_guesses_remaining = data.incorrect_guesses_remaining
      @guesses = data.guesses
      true
    else
      puts "Could not find '#{path}'"
      false
    end
  end

  def new_game_setup
    @word_to_guess = random_word
    @incorrect_guesses_remaining = 8
    @guesses = []
  end

  def out_of_guesses?
    @incorrect_guesses_remaining == 0
  end

  def path_to_save_name(path)
    path.gsub("saves/", "").gsub(".yaml", "")
  end

  def path_to_save_to
    print "Enter a name to save this game as (ex: 'bunny'): "
    dupe_index = 1
    input = gets.chomp.strip
    if input.empty?
      save_name = "0"
    else
      save_name = input
    end

    while File.exist?(save_name_to_path(save_name))
      save_name = "#{input}#{dupe_index}"
      dupe_index += 1
    end

    save_name_to_path(save_name)
  end

  def player_guess
    input = ""
    until input.length == 1 || input.length == @word_to_guess.length ||
          quit_cheat_or_save?(input)
      puts "Enter a letter or word to guess,"
      print "'quit' to quit, or 'save' to save and quit: "
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

  def prompt_and_process_guess
    puts spread_string("-" * 30)
    display_word_in_progress(@word_to_guess, @guesses)
    display_guesses
    curr_guess = player_guess
    handle_guess(curr_guess)
    curr_guess
  end

  def quit
    @end_game = true
  end

  def quit_cheat_or_save?(input)
    ["quit", "cheat", "save"].include?(input)
  end

  def random_word
    File.open("words.txt") do |file|
      words = file.readlines(chomp: true)
      words[rand(words.length)].strip
    end
  end

  def save
    path = path_to_save_to
    File.open(path, "w") do |file|
      YAML.dump(self, file)
    end
  end

  def save_name_to_path(save_name)
    "saves/#{save_name}.yaml"
  end

  def spread_string(str)
    out = ""
    str.each_char { |char| out << "#{char} " }
    out
  end

  def valid_letter_guess?(guess)
    guess.length == 1 && guess.downcase.between?("a", "z") &&
      !@guesses.include?(guess)
  end

  def valid_word_guess?(guess)
    guess.length == @word_to_guess.length &&
      all_chars_between?(guess.downcase, "a", "z")
  end

  def word_in_progress(word_to_guess, guesses)
    word = ""
    word_to_guess.each_char do |char|
      if guesses.include?(char)
        word << char
      else
        word << "_"
      end
    end
    word
  end
end
