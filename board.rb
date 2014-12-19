require_relative 'piece'
require 'colorize'
require 'io/console'

class Board
  attr_accessor :cursor, :start, :sequence

  def self.onboard?(pos)
    pos[0].between?(0, 7) && pos[1].between?(0, 7)
  end

  def initialize(fill_grid = true)
    make_starting_grid(fill_grid)
    @cursor = [0, 0]
    @sequence = []
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
    # print "  "; (0..7).each { |i| print "#{i.to_s}  " }
    # puts
    @grid.map.with_index do |row, i|
      # "#{i.to_s} ".concat(
      row.map.with_index do |piece, j|
        color = (i % 2 == j % 2 ? :grey : :red)
        if [i, j] == cursor
          piece.nil? ? "   ".colorize(:background => :light_blue) : "#{piece.render} ".colorize(:background => :light_blue)
        else
          piece.nil? ? "   ".colorize(:background => color) : "#{piece.render} ".colorize(:background => color)
        end
      end.join("")
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

  # Reads keypresses from the user including 2 and 3 escape character sequences.
  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  # oringal case statement from:
  # http://www.alecjacobson.com/weblog/?p=75
  def cursor_loop(msg)
    c = read_char

    case c
    when " "
      self.sequence << cursor
      true
    when "\r"
      self.sequence << cursor
      return false
    when "\e[A"
      updated_cursor = [cursor[0] - 1, cursor[1]]
      self.cursor = updated_cursor if Board.onboard?(updated_cursor)

      system "clear"
      puts msg
      puts render
      puts "cursor position: #{cursor.inspect}"
      true
    when "\e[B"
      updated_cursor = [cursor[0] + 1, cursor[1]]
      self.cursor = updated_cursor if Board.onboard?(updated_cursor)

      system "clear"
      puts msg
      puts render
      puts "cursor position: #{cursor}"
      true
    when "\e[C"
      updated_cursor = [cursor[0], cursor[1] + 1]
      self.cursor = updated_cursor if Board.onboard?(updated_cursor)

      system "clear"
      puts msg
      puts render
      puts "cursor position: #{cursor}"
      true
    when "\e[D"
      updated_cursor = [cursor[0], cursor[1] - 1]
      self.cursor = updated_cursor if Board.onboard?(updated_cursor)

      system "clear"
      puts msg
      puts render
      puts "cursor position: #{cursor}"
      true
    when "\u0003"
      puts "CONTROL-C"
      exit 0
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
