require_relative '00_tree_node'
require 'byebug'

class KnightPathFinder
  attr_reader :visited_positions

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

end

if __FILE__ == $PROGRAM_NAME
  kpf = KnightPathFinder.new([0,0])
  p kpf.find_path([7, 6]) # => [[0, 0], [1, 2], [2, 4], [3, 6], [5, 5], [7, 6]]
  p kpf.find_path([6, 2]) # => [[0, 0], [1, 2], [2, 0], [4, 1], [6, 2]]
  p kpf.find_path([0, 0]) # => [[0, 0]
  p kpf.find_path([0, 1]) # => [[0, 0], [1, 2], [2, 0], [0, 1]]
end
