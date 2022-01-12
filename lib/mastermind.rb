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
  COLOR_CHOICES = ['b', 'g', 'o', 'p', 'r', 'y']
  def initialize
    @board = Board.new
    @player_1 = nil
    @player_2 = nil
    @guess_set = COLOR_CHOICES.repeated_permutation(4).map(&:join)
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
    # # # binding.pry
    code = Display.prompt_code_entry(coder, coder_type, 'code', @guess_set)
    turn_count = 1
    loop do
      @board.show_board
      puts @guess_set.include? code.join()
      puts @guess_set.length
      p code
      # # binding.pry
      guess = Display.prompt_code_entry(guesser, guesser_type, 'guess', @guess_set[0].split(''))
      ## binding.pry
      temp_code = Array.new(code)
      @board.update_board(guess, temp_code, turn_count)
      if @board.check_victory(turn_count, guesser)
        break
      elsif guesser_type == 'computer'
        # binding.pry
        @guess_set = @board.refine_guesses(@guess_set, turn_count)
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
    # # # binding.pry
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
      # binding.pry
      if temp_code[index] == element
        temp_code[index] = '-'
        temp_guess[index] = ''
        arr.push('b')
      end
      if index == 3 # need to fix this for r y b b
        temp_guess.each do |remaining_element|
          if temp_code.include? remaining_element
            arr.push('w')
            temp_code.delete_at(temp_code.index(remaining_element))
          end
        end
        while arr.length < 4
          arr.push('x')
        end
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

  def refine_guesses(guess_set, turn_count)
    # binding.pry
    guess = @board[turn_count][0]
    clue = @board[turn_count][1]
    guess_set.select do |element|
      if element == 'ygbo' || element == 'bgpo'
        # binding.pry
      end
      temp_guess = Array.new(guess)
      difference = 4 - element.split('').each_with_index.reduce(0) do |sum, (color, index)|
        if temp_guess.include? color
          temp_guess.delete_at(temp_guess.index(color))
          sum += 1
        end
        sum
      end
      difference >= clue.count('x') && 4 - difference >= clue.count('b') + clue.count('w') && element.split('') != guess
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

  def self.prompt_code_entry(player_number, player_type, code_type, computer_guess)
    # # binding.pry
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
    elsif code_type == 'code'
      code = []
      (0..3).each do |index|
        code.push(COLOR_CHOICES[rand(0..5)])
      end
      return code
    else
      computer_guess
    end
  end

  def self.declare_victory
  end
end

new_game
