class Board2D

  def initialize( height, width, value = nil, options = {} )
    @board = Array.new(height) { Array.new(width) {value} }
    @height = height
    @width = width
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @board[row][col] = value
  end

  def in_bounds?(pos)
    valid_row?(pos[0]) && valid_col?(pos[1])
  end

  def valid_row?(row)
    row >=0 && row < height - 1
  end

  def valid_col?(col)
    col >= 0 && col < width - 1
  end

end
