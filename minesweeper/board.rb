require 'set'
require_relative 'tile'

class Board

  HEIGHT = 10
  LENGTH = 10      # May not be longer than 26 columns
  NUM_MINES = 10

  def self.make_deltas
    deltas = (-1..1).map { |x| (-1..1).map { |y| [x,y] }}.flatten(1)
    deltas.delete([0,0])
    deltas
  end

  DELTAS = Board.make_deltas

  def initialize(board, mine_tiles)
    @board = board
    @mine_positions = mine_tiles
    @flagged_positions = Set.new
    @letters = ("A".."Z").to_a.take(LENGTH)
    @unclicked_positions = get_all_positions.flatten
    puts "Mine positions:"
    p @mine_positions
  end

  def get_all_positions
    (0..HEIGHT-1).to_a.map { |num| @letters.map { |letter| [letter, num].join("") } }
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
    move_str = pos.join("")
    pos[0] = @letters.find_index(pos[0])
    tile = self[pos.reverse]
    if @unclicked_positions.include?(move_str)
      return true
    else
      return true if @flagged_positions.include?(pos) && choice == 'U'
      puts "Position #{move_str} has already been clicked. "
      false
    end
  end

  # pos is received as [col, row], action is F, C, or U (flag/click/unflag)
  def make_move(pos, action)
    puts "Received #{pos}, #{action} to board#make_move method"
    pos_str = [ @letters[pos[0]], pos[1] ].join("")
    pos = pos.reverse
    tile = self[pos]
    case action
      when 'U'
        unflagging_action(pos_str, tile)
      when 'F'
        flagging_action(pos_str, tile)
      when 'C'
        clicking_action(pos_str, tile, pos)
      else
        puts "Invalid action #{action}"
    end
  end

  def clicking_action(pos_str, tile, pos)
    if tile.flagged?
      puts "Cannot click #{pos_str} because the position is flagged, unflag it first"
      return
    elsif tile.revealed?
      puts "Position #{pos_str} has already been revealed"
      return
    else
      @unclicked_positions.delete(pos_str)
      tile.reveal
      unless tile.is_mine?
        reveal_neighboring_tiles(pos)
      end
    end
  end

  def reveal_neighboring_tiles(pos)
    return if self[pos].mines_touching > 0

    if self[pos].display == Tile::EMPTY
      neighboring_tiles = get_neighbors(pos)
      return if neighboring_tiles.empty?
      neighboring_tiles.each do |pos|
        puts "calling recursive_reveal on #{pos}"
        recursive_reveal(pos)
      end
    end
  end

  def recursive_reveal(pos)
    tile = self[pos]
    return if tile.revealed? || tile.flagged? || tile.is_mine?
    if tile.num_mines > 0
      tile.reveal
      @unclicked_positions.delete(pos)
    elsif tile.mines_touching == 0
      neighbors = get_neighbors(pos)
      neighbors.each { |neighbor_pos| recursive_reveal(neighbor_pos) }
    end
  end

  def get_neighbors(pos)
    neighbors = DELTAS.map.with_index do |delta|
      delta.map.with_index { |el, idx| el + pos[idx] }
    end
    neighbors.select { |neighbor| in_bounds?(neighbor) }
  end

  def unflagging_action(pos_str, tile)
    if tile.flagged?
      tile.unflag
      @flagged_positions.delete(pos_str)
      @unclicked_positions << pos_str
    else
      puts "Position #{pos_str} cannot be unflagged"
      return
    end
  end

  def flagging_action(pos_str, tile)
    if tile.flagged?
      puts "Position #{pos_str} is already flagged"
      return
    else
      tile.set_flagged
      @flagged_positions << pos_str
    end
  end

  def any_bombs_displaying?
    @mine_positions.each { |pos| return true if self[pos].displaying_bomb? }
  end

  def won?
    # Player loses if any positions are displaying mine symbols
    if any_bombs_displaying?
      puts "You lose!"
      return false
    end

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

    puts "game still in progress"
    puts "mine positions: #{@mine_positions.to_a.sort}"
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

  def in_bounds?(pos)
    row_in_bounds(pos[0]) && pos[1] >= 0 && pos[1] < @letters.length
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
