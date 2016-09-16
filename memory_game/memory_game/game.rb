require_relative 'board'
require_relative 'card'
require_relative 'human_player'


class Game

  def initialize
    @board = Board.new
  end

  def play
    until over?
      @board.render
      play_turn
    end
    "You win!"
  end

  def play_turn
    puts "Enter guess 1 in this format: row, col"
    guessed_pos1 = gets.chomp.split(", ").map{|idx| idx.to_i}
    @board.make_face_up(guessed_pos1)

    @board.render
    puts "Enter guess 2 in this format: row, col"
    guessed_pos2 = gets.chomp.split(", ").map{|idx| idx.to_i}
    @board.make_face_up(guessed_pos2)

    @board.render
    puts "Match!" if @board.cards_same?(guessed_pos1, guessed_pos2)
    sleep(1)
    unless @board.cards_same?(guessed_pos1, guessed_pos2)
      @board.make_face_down(guessed_pos1)
      @board.make_face_down(guessed_pos2)
    end

  end

  def over?
    @board.over?
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end
