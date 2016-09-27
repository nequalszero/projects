require 'set'
require_relative 'recursion_exercises'

class WordChainer
  def initialize(dictionary_file_name)
    @dictionary = assemble_dictionary(dictionary_file_name)
  end

  def assemble_dictionary(dictionary_file_name)
    words_array = File.readlines(dictionary_file_name)
    words_set = Set.new( words_array.map { |word| word.chomp } )
  end

  def adjacent_words(word)
    words = @dictionary.select { |d_word| one_letter_diff?(word, d_word) }
  end

  def one_letter_diff?(word1, word2)
    return false unless word1.length == word2.length
    mismatches = 0
    word1.each_char.with_index do |char, idx|
      mismatches += 1 unless char == word2[idx]
    end
    return false if mismatches >= 2
    true
  end

  def run(source, target)
    @current_words = [source]
    @all_seen_words = { source => nil}

    until @current_words.empty? || @all_seen_words.key?(target)
      explore_current_words
    end

    puts build_path(target)
  end

  def explore_current_words
    new_current_words = []

    @current_words.each do |c_word|
      adjacent_words(c_word).each do |adj_word|
        next if @all_seen_words.key?(adj_word)
        @all_seen_words[adj_word] = c_word
        new_current_words << adj_word
      end
    end

    # new_current_words.each do |word|
    #   puts "Word: #{word}, origin: #{@all_seen_words[word]}"
    # end
    @current_words = new_current_words
  end

  def build_path(target)
    path = [target]
    until target.nil?
      path << @all_seen_words[target]
      target = @all_seen_words[target]
    end
    path.reverse
  end

  # End of WordChainer class
end





if __FILE__ == $PROGRAM_NAME
  dictionary_file_name = 'dictionary.txt'
  game = WordChainer.new(dictionary_file_name)
  # puts game.adjacent_words("cat")
  game.run("duck", "door")
end
