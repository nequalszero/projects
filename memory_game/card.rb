
require_relative 'board'
require_relative 'game'

class Card
  attr_reader :val

  def initialize(val)
    @val = val
    @hidden = true
  end

  def reveal
    @hidden = false
  end

  def hidden?
    @hidden
  end

  def hide
    @hidden = true
  end

  def display
    card_array = [
      "######",
      "#    #",
      "# #{format_val} #",
      "#    #",
      "######"
    ]
    card_array[2] = "#    #" if hidden?
    card_array
  end

  def format_val
    return @val.to_s if @val >= 10
    " #{@val}"
  end

  def == (other_card)
    return true if self.val == other_card.val
    false
  end
end

def print(cards)
  display_array = []
  cards.each {|card| display_array << card.display}
  board = []
  (0..4).each do |idx| #height of card = 5
    row = []
    display_array.each do |card_array|
      row << card_array[idx]
    end
    board << row.join("     ")
  end
  board
end

if __FILE__ == $PROGRAM_NAME
  card1 = Card.new(7)
  card2 = Card.new(6, false)
  card3 = Card.new(5)
  card4 = Card.new(4)
  board = []
  board << print([card1, card2])
  board << print([card3, card4])
  puts board
end
