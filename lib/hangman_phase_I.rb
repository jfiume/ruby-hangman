# Hangman Phase I
# Human Guesses Word

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
    guess = guesser.guess
    letter_idxs = referee.check_guess(guess)
    unless letter_idxs.empty?
      letter_idxs.each do |idx|
        update_board(idx, guess)
      end
    end
    guesser.handle_response
  end

  def update_board(idx, match)
    @board[idx] = match
  end

  def won?
    @board == referee.secret_word
  end

  def play
    setup

    until won?
      take_turn
    end

    puts "#{referee.secret_word}"
    puts "You win!"
  end
end

class HumanPlayer

  def register_secret_length(length)
    secret_length = length
  end

  def guess
    puts "Please enter a guess:"
    guess = gets.chomp.strip.downcase
  end

  def handle_response
    # going to flesh this method out more later
  end
end

class ComputerPlayer

  attr_reader :dictionary, :secret_word

  def initialize(dictionary)
    @dictionary = dictionary
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
end


if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new
  dictionary = []
  File.foreach("lib/dictionary.txt") { |word| dictionary << word.strip }
  ref = ComputerPlayer.new(dictionary)
  game = Hangman.new({guesser: player1, referee: ref})
  game.play
end
