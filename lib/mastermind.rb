require 'pry-byebug'

def new_game
  game = Game.new
  game.play
  replay
end

def replay
  puts 'Replay game? y/n'
  replay_input = gets.chomp.downcase
  if replay_input == 'y'
    new_game
  else
    puts 'Game over'
  end
end

class Game
  def initialize
    @board = Board.new
    @player_1 = nil
    @player_2 = nil
  end

  def play
    create_player(1)
    create_player(2)
    if @player_1.side == "code"
      coder = 1
      coder_type = @player_1.player_type
      guesser = 2
      guesser_type = @player_2.player_type
    else
      coder = 2
      coder_type = @player_2.player_type
      guesser = 1
      guesser_type = @player_1.player_type
    end
    # binding.pry
    code = Display.prompt_code_entry(coder, coder_type)
    turn_count = 1
    loop do
      @board.show_board
      guess = Display.prompt_code_entry(guesser, guesser_type)
      # binding.pry
      temp_code = Array.new(code)
      @board.update_board(guess, temp_code, turn_count)
      if @board.check_victory(turn_count, guesser)
        break
      end
      turn_count += 1
    end
  end

  def create_player(player_number)
    name = Display.prompt_name(player_number)
    player_type = Display.prompt_human(player_number)
    if player_number == 1
      side = Display.prompt_side(player_number)
    else
      side = @player_1.side == "guess" ? "code" : "guess"
    end
    # binding.pry
    if player_number == 1
      @player_1 = Player.new(name, player_type, side)
    else
      @player_2 = Player.new(name, player_type, side)
    end
  end
end

class Board
  VICTORY = Array.new(4, 'b')
  def initialize
    @board = Hash.new()
    (1..12).each do |i|
      @board[i] = [Array.new(4, '_'), Array.new(4, '_')]
    end
  end

  def show_board
    puts "        Guesses                      Clues"
    @board.each do |key, value|
      puts "[  #{value[0][0]}  ][  #{value[0][1]}  ][  #{value[0][2]}  ][  #{value[0][3]}  ] || [  #{value[1][0]}  ][  #{value[1][1]}  ][  #{value[1][2]}  ][  #{value[1][3]}  ]"
    end
  end

  def update_board(guess, temp_code, turn_count)
    # binding.pry
    @board[turn_count][0] = guess
    temp_guess = Array.new(guess)
    @board[turn_count][1] = temp_guess.each_with_index.reduce([]) do |arr, (element, index)|
      binding.pry
      if temp_code[index] == element
        temp_code[index] = '-'
        temp_guess[index] = ''
        arr.push('b')
      elsif index == 3 && (temp_guess & temp_code != [])
        (0...(temp_guess & temp_code).length).each do
          arr.push('w')
        end
      else
        arr.push('x')
      end
      arr.sort()
    end
  end

  def check_victory(turn_count, guesser)
    if @board[turn_count][1] == VICTORY
      show_board
      puts "Player #{guesser} wins!"
      return 1
    elsif turn_count == 12
      show_board
      puts "Player #{3-guesser} wins!"
      return 1
    end
  end
end

class Player
  attr_reader :name, :player_type, :side

  def initialize(name, player_type, side)
    @name = name
    @player_type = player_type
    @side = side
  end
end

class Display
  COLOR_CHOICES = ['b', 'g', 'o', 'p', 'r', 'y']
  def self.prompt_name(player_number)
    puts "Please provide name of Player #{player_number}"
    gets.chomp.downcase
  end

  def self.prompt_human(player_number)
    while 1
      puts "Will Player #{player_number} be human or computer?"
      response = gets.chomp.downcase
      if response == "human"
        return "human"
      elsif response == "computer"
        return "computer"
      else
        puts "Error: please type 'human' or 'computer'"
      end
    end
  end

  def self.prompt_side(player_number)
    if player_number == 1
      while 1
        puts "Will Player #{player_number} be guesser or coder?"
        response = gets.chomp.downcase
        if response == "guesser"
          return "guess"
        elsif response == "coder"
          return "code"
        else
          puts "Error: please type 'guesser' or 'coder'"
        end
      end
    end
  end

  def self.prompt_code_entry(player_number, player_type)
    # binding.pry
    if player_type == "human"
      puts <<-HEREDOC

        Player #{player_number}, please enter a code in the format of 'a b c d'

        'b' = blue
        'g' = green
        'o' = orange
        'p' = pink
        'r' = red
        'y' = yellow

      HEREDOC

      loop do
        result = gets.chomp
        result = result.split()
        if result.length == 4 && result.all? { |element| COLOR_CHOICES.include?(element) }
          return result
        else
          puts "Try again.  Letters must all be in given list and array of length 4"  
        end
      end
    else
      code = []
      (0..3).each do |index|
        code.push(COLOR_CHOICES[rand(0..5)])
      end
      return code
    end
  end

  def self.declare_victory
  end
end

new_game
