require 'colorize'

class Tile

  def initialize(value)
    @value = value
    @color = :white
  end

  def set_color(color)
    @color = color
  end

  def display
    @value.colorize(@color).encode('utf-8')
  end

  def set_value(value)
    @value = value
  end

end
