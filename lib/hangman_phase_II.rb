# Hangman Phase II
# Computer Guesses Letters Randomly

class Hangman
  attr_reader :guesser, :referee, :board

  def initialize(players = { })
    @players = {
      guesser: 'player1',
      referee: 'player2',
    }.merge(players)
    @board = ""
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
    puts @board
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
    @board.chars.none? { |letter| letter == "_"} && referee.dictionary.index(@board)
  end

  def play
    setup

    until won?
      take_turn
    end

    puts "#{@board}"
    puts "Winner! Game Over!"
  end
end

class HumanPlayer

  def register_secret_length(length)
    secret_length = length
  end

  def guess(board = nil)
    puts "Please enter a guess: "
    guess = gets.chomp.strip.downcase
  end

  def handle_response(guess, letter_idxs)

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
      indices = gets.chomp.strip.split(" ").map! {|el| el.to_i}
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
    ("a".."z").to_a.sample
  end

  def handle_response(letter, arr)

  end
end


if __FILE__ == $PROGRAM_NAME
  dictionary = []
  File.foreach("lib/dictionary.txt") { |word| dictionary << word.strip }
  ref = HumanPlayer.new
  player1 = ComputerPlayer.new(dictionary)
  game = Hangman.new({guesser: player1, referee: ref})
  game.play
end
