require_relative 'tile'
require 'colorize'

class Board

  SORTED_ROW = ("1".."9").to_a

  def initialize(board)
    @board = board
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, val)
    row, col = pos
    @board[row][col] = pos
  end

  def self.from_file(file)
    # raw board will be a 2D array of strigified integers
    raw_board = File.readlines(file).map { |row| row.chomp.split("") }
    Board.new( self.make_new_board(raw_board) )
  end

  def self.make_new_board(raw_board)
    new_board = Array.new(9) { Array.new }
    raw_board.each_with_index do |row, idx|
      row.each { |val| new_board[idx] << Tile.new(val, true) }
    end
    new_board
  end

  def render
    render_columns_labels
    @board.each_with_index do |row, idx|
      puts render_row(row, idx)
      puts " "*9 + "="*37 if idx == 2 || idx == 5
      puts " "*20 + "||" + " "*11 + "||" \
           unless idx == 2 || idx == 5 || idx == 8
      puts if idx == 8
    end
  end

  def render_columns_labels
    col_string = "columns:   ".colorize(:cyan)
    (0..8).each do |idx|
      col_string += "#{idx}".colorize(:cyan)
      col_string += "  " unless idx == 2 || idx == 5
      col_string += "      " if idx == 2 || idx == 5
    end
    puts
    puts col_string
    puts
  end

  def render_row(row_array, idx)
    row_string = "  row #{idx}:   ".colorize(:light_green)
    row_array.each_with_index do |tile, idx|
      color = :green
      color = :red if tile.given?
      row_string += " " if tile.value == "0"
      row_string += tile.value.colorize(color) unless tile.value == "0"
      row_string += "  " unless idx == 2 || idx == 5
      row_string += "  ||  " if idx == 2 || idx == 5
    end
    row_string
  end

  def solved?
    return false unless check_rows?
    return false unless check_cols?
    return false unless check_squares?
    true
  end

  def check_rows?(board = @board)
    board.each do |row|
      return false unless row_complete?( row.map{ |tile| tile.value } )
    end
    true
  end

  def row_complete?(row_values)
    return true if row_values.sort == SORTED_ROW
    false
  end

  def check_cols?
    board_transpose = @board.transpose
    check_rows?(board_transpose)
  end

  def check_squares?
    (0..2).each do |idx1|
      (0..2).each do |idx2|
        square_values = get_square(3*idx1, 3*idx2)
        return false unless row_complete?(square_values)
      end
    end
  end

  def get_square(row_idx, col_idx)
    values = []
    (row_idx..row_idx+2).each do |row|
      (col_idx..col_idx+2).each do |col|
        values << self[[row, col]].value
      end
    end
    values
  end

end

if $PROGRAM_NAME == __FILE__
  file1 = 'sudoku1_almost.txt' # upper left corner incomplete
  file2 = 'sudoku2_almost.txt' # upper left corner incomplete
  file3 = 'sudoku1-solved.txt'
  new_board = Board.from_file(file3)
  new_board.render
  puts "board solved: #{new_board.solved?}"
end
