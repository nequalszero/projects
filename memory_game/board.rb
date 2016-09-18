require_relative 'card'
require_relative 'game'

GRID_SIZE ||= 2

class Board

  attr_reader :grid

  def self.blank_grid
    new_cards = Board.new_card_set
    Board.populate_grid(new_cards)
  end

  def self.populate_grid(new_cards)
    grid = Array.new(GRID_SIZE) {Array.new(GRID_SIZE)}
    GRID_SIZE.times do |row|
      GRID_SIZE.times do |col|
        grid[row][col] = new_cards.pop
      end
    end
    grid
  end

  def self.new_card_set
    new_cards = []
    num_cards = (GRID_SIZE ** 2) / 2
    (0...num_cards).each do |num|
      2.times {new_cards << Card.new(num)}
    end
    new_cards.shuffle
  end

  def initialize
    @grid = Board.blank_grid
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, val)
    row, col = pos
    @grid[row][col] = value
  end

  def render
    system('clear')
    @grid.each do |cards|
      print_cards(cards)
    end
  end

  def over?
    @grid.each do |cards|
      return false if cards.any?{ |card| card.hidden? }
    end
    true
  end

  def make_face_up(pos)
    card = self[pos]
    card.reveal
  end

  def make_face_down(pos)
    card = self[pos]
    card.hide
  end

  def cards_same?(pos1, pos2)
    self[pos1] == self[pos2]
  end

  def print_cards(cards)
    display_array = []
    cards.each {|card| display_array << card.display}
    board = []
    (0..4).each do |idx| #height
      row = []
      display_array.each do |card_array|
        row << card_array[idx]
      end
      board << row.join("  ")
    end
    puts board
  end

end
#
# p Board.blank_grid
#


if __FILE__ == $PROGRAM_NAME
  grid = Board.blank_grid
  grid.each do |card_array|
   print(card_array)
 end
end
