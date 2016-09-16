require 'colorize'

$BACKGROUND = :blue

class Tile
  FLAG = '⚑'
  BOMB = '💣'
  EMPTY = ' '
  UNCLICKED = '-'

  TILE_COLORS = {
    '1' => :light_blue,
    '2' => :cyan,
    '3' => :green,
    '4' => :magenta,
    '5' => :red,
    '6' => :light_magenta,
    '7' => :light_green,
    '8' => :light_yellow,
    FLAG => :white
  }

  def initialize
    @mines_touching = 0
    @mine = false
    @clicked = false
    @display_value = UNCLICKED
    @flagged = false
  end

  def reveal
    @clicked = true
    @display_value = set_display_value
  end

  def revealed?
    @clicked
  end

  def flagged?
    @flagged
  end

  def display
    @display_value
  end

  def set_display_value
    @display_value = @mines_touching.to_s
    @display_value = EMPTY if @mines_touching == 0
    @display_value = BOMB if is_mine?
    @display_value = FLAG if flagged?
    @display_value = @display_value.colorize(TILE_COLORS[@display_value])
  end

  # def set_flag
  #   @display_value = FLAG
  # end

  def is_mine?
    @mine
  end

  def set_mine
    @mine = true
    set_display_value
  end

  def displaying_bomb?
    @display_value == BOMB
  end

  def increment_mines
    @mines_touching += 1
    set_display_value
  end

end

if __FILE__ == $PROGRAM_NAME

end
