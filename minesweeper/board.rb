require 'set'
require_relative 'tile'

class Board

  HEIGHT = 10
  LENGTH = 16       # May not be longer than 26 columns
  NUM_MINES = 50

  def initialize(board, mine_tiles)
    @board = board
    @mine_positions = mine_tiles
    @flagged_positions = Set.new
    @letters = ("A".."Z").to_a.take(LENGTH)
    @unclicked_positions = 
  end

  def self.new_board
    mine_tiles = get_new_mine_set
    board = Array.new(HEIGHT) { Array.new(LENGTH) { Tile.new } }
    assign_mines(board, mine_tiles)
    update_adjacent_squares(board, mine_tiles)
    Board.new(board, mine_tiles)
  end

  # board is 2d array and mine_tiles is a Set of mine positions
  def self.assign_mines(board, mine_tiles)
    mine_tiles.each do |pos|
      row, col = pos
      board[row][col].set_mine
    end
  end

  def self.update_adjacent_squares(board, mine_tiles)
    deltas = make_deltas

    mine_tiles.each do |pos|
      row, col = pos
      deltas.each do |delta|
        new_pos = [row + delta[0], col + delta[1]]
        board[new_pos[0]][new_pos[1]].increment_mines if
          incrementable?(new_pos, board)
      end
    end
  end

  def self.make_deltas
    deltas = []
    (-1..1).each do |row_inc|
      (-1..1).each do |col_inc|
        deltas << [row_inc, col_inc] unless [row_inc, col_inc] == [0,0]
      end
    end

    deltas
  end

  def self.incrementable?(pos, board)
    row, col = pos
    return false if row < 0 || col < 0 || row >= HEIGHT || col >= LENGTH
    return false if board[row][col].is_mine?
    true
  end

  def self.get_new_mine_set
    NUM_MINES.fdiv(HEIGHT * LENGTH) <= 0.33 ? small_mine_set : large_mine_set
  end

  def self.small_mine_set
    mine_set = Set.new
    until mine_set.length == NUM_MINES
      mine_set.add([rand(0...HEIGHT), rand(0...LENGTH)])
    end

    mine_set
  end

  def self.large_mine_set
    mine_set = []
    (0...HEIGHT).each do |row|
      (0...LENGTH).each do |col|
        mine_set << [row, col]
      end
    end

    mine_set.shuffle.take(NUM_MINES)
  end

  # Receives a move in the form [coordinate, choice] where
  #   coordinate is a string like A11 and choice is F/C/U
  def valid_move?(move)
    puts "Move: #{move}"
    pos, choice = move
    pos[0] = @letters.find_index(pos[0])
    tile = self[pos.reverse]
    if @unclicked_positions.include?(pos)
      return true
    else
      return true if @flagged_positions.include?(pos) && choice == 'U'
      puts "Position #{pos} has already been clicked. "
      false
    end
  end

  def won?
    # Player loses if any positions are displaying mine symbols
    return false if @mine_positions.any? { |pos| self[pos].displaying_bomb }

    # Player wins if all mine positions are flagged with no extra flags out
    return true if @mine_positions.length == @flagged_positions &&
      @mine_positions.all? { |pos| @flagged_positions.include?(pos) }

    # Player wins if the only unclicked tiles remaining are the mine tiles
    return true if @mine_positions.length == @unclicked_positions &&
      @mine_positions.all? { |pos| @unclicked_positions.include?(pos) }

    # Player wins if the number of unclicked tiles and number of flagged
    # tiles sums to the number of mines remaining
    return true if @mine_positions.length == @unclicked_positions.length +
      @flagged_positions.length

  end

  def render
    render_column_label
    render_border
    @board.each_with_index { |row, idx| render_row(row, idx) }
    render_border
  end

  def render_column_label
    column_label =  "     " + @letters.join("  ") + "   "
    puts column_label.colorize(:background => $BACKGROUND)
  end

  def render_border
    border = "   +-" + ("-" * (3 * LENGTH - 2)) + "-+ "
    puts border.colorize(:background => $BACKGROUND)
  end

  def render_row(row, idx)
    display_arr = row.map { |tile| tile.display }
    row_string =  "#{padded_num(idx)} | " + display_arr.join("  ") + " | "
    puts row_string.colorize(:background => $BACKGROUND)
  end

  def padded_num(num)
    return " #{num}" if num < 10
    "#{num}"
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def column_in_bounds?(col)
    @letters.include?(col)
  end

  def row_in_bounds?(row)
    (0..HEIGHT).to_a.include?(row)
  end

end

if __FILE__ == $PROGRAM_NAME
  board = Board.new_board
  board.render
end
