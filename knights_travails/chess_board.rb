require_relative 'standard_boards'

class ChessBoard < Board2D

  def initialize( height, width, value = nil, options = {} )
    @board = Array.new(height) { Array.new(width) {Tile.new(value)} }
    @height = height
    @width = width
  end

  def render
    render_column_label
    render_border
    @board.each_with_index { |row, idx| render_row(row, idx) }
    render_border
  end

  def render_column_label
    column_label =  "     " + (0..@height-1).to_a.join("  ") + "   "
    puts column_label
  end

  def render_border
    border = "   +-" + ("-" * (3 * @width - 2)) + "-+ "
    puts border
  end

  def render_row(row, idx)
    display_arr = row.map { |tile| tile.display }
    row_string =  " #{idx} | " + display_arr.join("  ") + " | "
    puts row_string
  end
end
