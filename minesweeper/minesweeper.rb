require 'set'
require_relative 'tile'
require_relative 'board'

class MineSweeper

  def initialize
    @board = Board.new_board
  end

  def play
    status = nil
    while status.nil?
      move = prompt_move
      puts "Successful move given! #{move}"
      status = won?
    end
  end

  def prompt_move
    while true
      @board.render
      coordinates = prompt_coordinates
      choice = prompt_choice(coordinates)
      move = [coordinates, choice]
      break if @board.valid_move?(move)
    end
    move
  end

  def prompt_choice(coordinates)
    while true
      puts "Enter action: flag, click, or unflag (F/C/U): "
      print "> "
      choice = gets.chomp.upcase
      break if valid_choice?(coordinates, choice)
    end
    choice
  end

  def valid_choice?(coordinates, choice)
    return false unless choice.length == 1 && choice =~ /[FCU]/
    true
  end

  def prompt_coordinates
    while true
      puts "Enter coordinates to modify (example: 'A3'): "
      print "> "
      coordinates = gets.chomp
      break if valid_coordinates?(coordinates)
    end

    # Returns [letter, number]
    [coordinates[0], Integer(coordinates[1..-1])]
  end

  def valid_coordinates?(coordinates)
    if coordinates.length < 2 || coordinates.length > 3
      puts "Invalid coordinates #{coordinates}, enter a move like B6 or C10"
      return false
    end

    col = coordinates[0]
    return false unless valid_column?(col)

    row = coordinates[1..-1]
    return false unless valid_row?(row)

    true
  end

  def valid_column?(col)
    puts "Invalid column selection: '#{col}', column should be a letter." \
      unless col =~ /[A-Z]/
    @board.column_in_bounds?(col)
  end

  def valid_row?(row)
    row.each_char { |char| return false unless char =~ /[0-9]/ }
    @board.row_in_bounds?(Integer(row))
  end

  def won_or_lost?
    @board.won?
  end

end


if __FILE__ == $PROGRAM_NAME
  new_game = MineSweeper.new
  new_game.play

end
