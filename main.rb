require 'pry-byebug'
require 'yaml'

module Dictionary
  def choose_random_word(min_length, max_length, file)
    count_lines = 0

    while !file.eof?
      line = file.readline
      count_lines += 1
    end

    file.rewind

    random_word = ""
    # contents = file.readlines
    # file.rewind
    # puts contents.length
    # puts count_lines
    # line = file.readline
    # puts line
    # file.rewind

    while random_word.length < min_length || random_word.length > max_length
      line_number = rand(count_lines)
      # line_number = count_lines-1
      (line_number+1).times { line = file.readline }
      random_word = line.strip
    end
    random_word
  end
end

class Board
  include Dictionary
  attr_accessor :guesses
  attr_reader :max_guesses
  attr_reader :letters_left
  def initialize(max_guesses, guesses=0, letters_chosen=[], word="", letters_left=[], word_in_progress=[])
    @guesses = guesses
    @max_guesses = max_guesses
    @letters_chosen = letters_chosen
    @word = word
    @letters_left = letters_left
    @word_in_progress = word_in_progress
  end

  def choose_word(min_length, max_length, file = nil)
    @word = choose_random_word(min_length, max_length, file)
    @letters_left = @word.split("").uniq
    @word_in_progress = Array.new(@word.length)
    puts @word
  end

  def display
    if @letters_chosen.length == 0
      puts "You have not guessed any letters"
      puts ""
    else
      puts "You have guessed the following letters: "
      p @letters_chosen
      puts ""
    end

    @word_in_progress.each do |x|
      if x == nil
        print " _ "
      else
        print " #{x} "
      end
    end

    puts ""
  end

  def guess_letter(letter)
    
    if @letters_chosen.include?(letter)
      puts "That letter was already guessed"
    else
      @guesses += 1
      @letters_chosen << letter
      if @letters_left.include?(letter)
        @letters_left.delete(letter)
        word_copy = @word.split("")
        while word_copy.include?(letter)
          index = word_copy.index(letter)
          @word_in_progress[index] = letter
          word_copy[index] = nil
        end
      end
    end
  end

  def to_yaml
    YAML.dump({
      :guesses => @guesses,
      :max_guesses => @max_guesses,
      :letters_left => @letters_left,
      :letters_chosen => @letters_chosen,
      :word => @word,
      :word_in_progress => @word_in_progress
    })
  end

  def self.from_yaml(string)
    data = YAML.load string
    p data
    #max_guesses, guesses=0, letters_chosen=[], word="", letters_left=[], word_in_progress=[]
    self.new(data[:max_guesses], data[:guesses], data[:letters_chosen], data[:word], data[:letters_left], data[:word_in_progress])
  end

end


file = File.open("google-10000-english-no-swears.txt", "r")
dirname = "save-files"
Dir.mkdir(dirname) unless File.exists?dirname

board = Board.new(10)
board.choose_word(5, 12, file)

input = ""

while input.downcase != "quit" && input.downcase != "exit" 
  board.display

  if board.letters_left.length == 0
    puts ""
    puts "You win!"
    break
  end

  if board.guesses >= board.max_guesses
    puts ""
    puts "You lose!"
    break
  end

  puts "You have #{board.max_guesses- board.guesses} guesses left."
  puts ""
  puts ""
  puts "Guess a letter or 'save' to save game or 'load' to load game: "
  input = gets.chomp.downcase
  if input.length == 1
    board.guess_letter(input)
    puts ""
    puts ""
  elsif input.downcase == "save"
    puts "Enter filename to save under: "
    
    fname = gets.chomp
    fname = "#{dirname}/#{fname}.txt"
    savefile = File.open(fname, "w")
    savefile.puts board.to_yaml
    savefile.close
  elsif input.downcase == "load"
    puts Dir.glob("*", base: dirname)
    puts "Enter a filename to load: "
    fname = gets.chomp
    loadfile = File.open("#{dirname}/#{fname}")
    contents = loadfile.read
    board = Board.from_yaml(contents)
  end

  
end