require_relative 'piece'
require 'colorize'

class Board

  def self.onboard?(pos)
    pos[0].between?(0, 7) && pos[1].between?(0, 7)
  end

  def initialize(fill_grid = true)
    make_starting_grid(fill_grid)
  end

  def [](pos)
    x, y = pos
    @grid[x][y]
  end

  def []=(pos, value)
    x, y = pos
    @grid[x][y] = value
  end

  def empty?(pos)
    self[pos].nil?
  end

  def pieces
    @grid.flatten.compact
  end

  def dup
    new_board = Board.new(false)

    pieces.each do |piece|
      new_board[piece.pos] = piece.class.new(new_board, piece.color, piece.pos, piece.kinged)
    end

    new_board
  end

  def render
    print "  "; (0..7).each { |i| print "#{i.to_s}  " }
    puts
    @grid.map.with_index do |row, i|
      "#{i.to_s} ".concat(
      row.map.with_index do |piece, j|
        color = (i % 2 == j % 2 ? :grey : :red)
        piece.nil? ? "   ".colorize(:background => color) : "#{piece.render} ".colorize(:background => color)
      end.join(""))
    end.join("\n")
  end

  def over?
    pieces.none? { |piece| piece.color == :red } ||
    pieces.none? { |piece| piece.color == :black }
  end

  def winner
    if pieces.any? { |piece| piece.color == :red }
      :red
    else
      :black
    end
  end

  private
  def make_starting_grid(fill_board)
    @grid = Array.new(8) { Array.new(8) }
    return if fill_board == false

    @grid.each_index do |i|
      @grid.each_index do |j|
        next if i.between?(3,4)
        pos = [i, j]
        current_color = ((i < 3) ? :black : :red)
        self[pos] = Piece.new(self, current_color, pos) if i % 2 == j % 2
      end
    end
    @grid
  end
end
