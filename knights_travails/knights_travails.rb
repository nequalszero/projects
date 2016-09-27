require_relative '00_tree_node'
require_relative 'chess_board'
require_relative 'tile'
require 'byebug'

class KnightPathFinder
  attr_reader :visited_positions

  WHITE_KNIGHT = "♘"
  BLACK_KNIGHT = "♞"
  EMPTY_SPACE = "-"
  COLORS = {
            :start => :red,
            :previous => :yellow,
            :final => :green
                                  }
  DELTAS = [
            [1, 2],
            [1, -2],
            [-1, 2],
            [-1, -2],
            [2, 1],
            [2, -1],
            [-2, 1],
            [-2, -1]
                    ]

  def initialize(pos)
    raise "error position #{pos} out of bounds" if pos.any? { |el| el < 0 || el > 7}
    @pos = pos
    @visited_positions = [@pos]
    @move_tree = build_move_tree
  end

  def new_move_positions(pos)
    new_moves = self.class.valid_moves(pos) - @visited_positions
    @visited_positions.concat(new_moves)
    new_moves
  end

  def build_move_tree
    root_node = PolyTreeNode.new(@pos)
    queue = [root_node]

    until queue.empty?
      current_node = queue.shift
      new_positions = (new_move_positions(current_node.value))
      new_children = new_positions.map {|pos| PolyTreeNode.new(pos)}
      new_children.each { |node| node.parent = current_node}
      queue.concat(new_children)
    end

    root_node
  end

  def self.valid_move?(pos)
    pos.none? {|el| el < 0 || el > 7}
  end

  def self.valid_moves(pos)
    result = []
    DELTAS.each do |delta|
      new_pos = delta.map.with_index {|el, idx| el + pos[idx]}
      result << new_pos if self.valid_move?(new_pos)
    end
    result
  end

  def find_path(end_pos)
    target_node = @move_tree.bfs(end_pos)
    return nil if target_node.nil?
    trace_path_back(target_node)
  end

  def trace_path_back(target_node)
    path = [target_node.value]
    until target_node.parent.nil?
      target_node = target_node.parent
      path << target_node.value
    end
    path.reverse
  end

  def clear_screen
    #system('clear')
    puts "\e[H\e[2J"    # Clears the screen
  end

  def render_path(path)
    @chess_board = ChessBoard.new(8, 8, EMPTY_SPACE)
    @past_positions = []

    path.each_with_index do |pos, idx|
      clear_screen
      current_tile = @chess_board[pos]
      current_tile.set_value(WHITE_KNIGHT)
      current_tile.set_color(COLORS[:final])
      current_tile.set_color(COLORS[:start]) if idx == 0
      recolor_past_tiles
      @past_positions << pos unless idx == 0  # don't recolor the start tile
      @chess_board.render
      sleep(1)
    end

  end

  def recolor_past_tiles
    @past_positions.each { |pos| @chess_board[pos].set_color(COLORS[:previous]) }
  end

end

if __FILE__ == $PROGRAM_NAME
  kpf = KnightPathFinder.new([0, 6])
  path = kpf.find_path([1, 7])
  kpf.render_path(path)
  # p kpf.find_path([7, 6]) # => [[0, 0], [1, 2], [2, 4], [3, 6], [5, 5], [7, 6]]
  # p kpf.find_path([6, 2]) # => [[0, 0], [1, 2], [2, 0], [4, 1], [6, 2]]
  # p kpf.find_path([0, 0]) # => [[0, 0]
  # p kpf.find_path([0, 1]) # => [[0, 0], [1, 2], [2, 0], [0, 1]]
end
