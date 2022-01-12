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
    Display.new
  end

  def play
    create_player(1)
    create_player(2)
    if @player_1.side == "code"
      code = Display.prompt_code_entry(1)
    else
      code = Display.prompt_code_entry(2)
    end
    loop do
      show_board
      prompt_guess
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
    if player_number == 1
      @player_1 = Player.new(name, player_type, side)
    else
      @player_2 = Player.new(name, player_type, side)
    end
  end
end

class Board
  def initialize
    # binding.pry
    @board = Hash.new()
    (1..12).each do |i|
      @board[i] = [Array.new(4), Array.new(4)]
    end
  end

  def show_board
  end

  def update_board
  end

  def check_victory
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

  def self.prompt_name(player_number)
    puts "Please provide name of player #{player_number}"
    gets.chomp.downcase
  end

  def self.prompt_human(player_number)
    while 1
      puts "Will Player #{player_number} be human or computer?"
      response = gets.chomp.downcase
      if response == "human"
        "human"
        break
      elsif response == "computer"
        "computer"
        break
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
          "guess"
          break
        elsif response == "coder"
          "code"
          break
        else
          puts "Error: please type 'guesser' or 'coder'"
        end
      end
    end
  end

  def self.prompt_code_entry(player_number)
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
      if result.length == 4 && result.all? { |element| ['b', 'g', 'o', 'p', 'r', 'y'].include?(element) }
        result
        break
      else
        puts "Try again.  Letters must all be in given list and array of length 4"  
      end
    end
  end

  def self.prompt_guess
  end
end

new_game
