# Hangman Phase III
# Computer Guesses Intelligently

class Hangman
  attr_reader :guesser, :referee, :board

  def initialize(players = { })
    @players = {
      guesser: 'player1',
      referee: 'player2',
    }.merge(players)
    @board = []
  end

  def guesser
    @players[:guesser]
  end

  def referee
    @players[:referee]
  end

  def board
    @board
  end

  def setup
    secret_length = referee.pick_secret_word
    guesser.register_secret_length(secret_length)
    secret_length.times { @board << "_" }
  end

  def take_turn
    puts @board.join
    guess = guesser.guess(@board)
    letter_idxs = referee.check_guess(guess)
    unless letter_idxs.empty?
      letter_idxs.each do |idx|
        update_board(idx, guess)
      end
    end
    guesser.handle_response(guess, letter_idxs)
  end

  def update_board(idx, match)
    @board[idx] = match
  end

  def won?
    @board.none? { |letter| letter == "_"} && referee.dictionary.index(@board.join)
  end

  def lost?
    @board.none? { |letter| letter == "_"} && !referee.dictionary.index(@board.join) || guesser.guess(@board) == "_"
  end

  def play
    setup

    until won? || lost?
      take_turn
    end

    if won?
      puts "#{@board.join}"
      puts "Winner! Game Over!"
    else
      puts "#{@board.join}"
      puts "Sorry, you lost!"
    end
  end
end

class HumanPlayer

  attr_reader :dictionary, :guessed_letters

  def initialize(dictionary)
    @dictionary = dictionary
  end

  def guessed_letters(guess)
    @guessed_letters = [] unless @guessed_letters
    @guessed_letters << guess if guess.length == 1
    @guessed_letters
  end

  def register_secret_length(length)
    secret_length = length
  end

  def guess(board = nil)
    puts "Please enter a guess: "
    guess = gets.chomp.strip.downcase
  end

  def handle_response(guess, letter_idxs)
    guessed_letters = guessed_letters(guess)
    puts "Previously guessed letters: #{guessed_letters.join(", ")}"
  end

  def pick_secret_word
    puts "Please enter the length of the secret word:"
    length_word = gets.chomp.strip.to_i
  end

  def check_guess(letter)
    puts "Is #{letter} in the secret word?"
    print "y for yes or n for no      "
    response = gets.chomp.strip.downcase
    if response == "y"
      puts "Please enter the index or indecies where the letter occurs in the secret word:"
      indices = gets.chomp.strip.split(",").map! {|el| el.to_i}
      return indices
    else
      return []
    end
  end
end

class ComputerPlayer

  attr_reader :dictionary, :secret_word

  def initialize(dictionary)
    @dictionary = dictionary
  end

  def register_secret_length(length)
    secret_length = length
    dictionary.select! { |word| word.length == secret_length }
  end

  def pick_secret_word
    @secret_word = dictionary.sample
    secret_word.length
  end

  def check_guess(letter)
    letter_idx = []

    secret_word.each_char.with_index do |char, idx|
      letter_idx << idx if char == letter
    end

    letter_idx
  end

  def guess(board)
    dictionary_hash = Hash.new(0)

    dictionary.each do |word|
      word.each_char do |char|
        dictionary_hash[char] += 1
      end
    end

    board.compact.each do |letter|
      dictionary_hash[letter] = 0
    end

    dictionary_hash.sort_by { |letters, values| values }.last.first
  end

  def handle_response(letter, arr)
    counter = Hash.new(0)

    if arr.empty?
      dictionary.reject! { |word| word.include?(letter) }
    else
      dictionary.each do |word|
        word.each_char do |char|
          counter[word] += 1 if char == letter
        end
      end

      arr.each do |idx|
        dictionary.select! do |word|
          word[idx] == letter && counter[word] == arr.length
        end
      end
    end
  end

  def candidate_words
    dictionary
  end
end


if __FILE__ == $PROGRAM_NAME
  dictionary = []
  File.foreach("lib/dictionary.txt") { |word| dictionary << word.strip }
  ref = HumanPlayer.new(dictionary)
  player1 = ComputerPlayer.new(dictionary)
  game = Hangman.new({guesser: player1, referee: ref})
  game.play
end
