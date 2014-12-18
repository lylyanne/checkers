require_relative 'board'

class InvalidMoveError < StandardError
end

class Checkers
  attr_reader :board, :players, :turn_colors

  def initialize(player1, player2)
    @board = Board.new
    @players = [player1, player2]
    @turn_colors = { player1 => :red, player2 => :black }
  end

  def play

    until board.over?
      puts "#{turn_colors.key(:red).name} is red"
      puts "#{turn_colors.key(:black).name} is black"
      begin
        puts board.render
        puts "#{turn_colors[players[0]].to_s}'s turn"
        start, sequence = players[0].play_turn

        raise InvalidMoveError.new "empty starting pos" if board.empty?(start)
        raise InvalidMoveError.new "Not your piece" if board[start].color != turn_colors[players[0]]
        board[start].perform_moves(sequence)
      rescue InvalidMoveError => e
        puts e.message
        retry
      end
      @players.rotate!
    end

    puts board.render
    puts "#{turn_colors.key(board.winner).name} wins"
    puts "Fun's over. Back to work!"
  end
end

class HumanPlayer

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def play_turn
    sequence = []
    print "Enter a starting position (e.g. 2 0): "
    start_x, start_y = gets.chomp.split(" ").map(&:to_i)
    raise InvalidMoveError.new "Invalid input" if start_x.nil? || start_y.nil?

    print "Enter a move sequence (e.g. 4 4;6 6): "
    player_moves = gets.chomp.split(";")
    until player_moves.empty?
      move_x, move_y = player_moves.shift.split(" ").map(&:to_i)
      raise InvalidMoveError.new "Invalid input" if start_x.nil? || start_y.nil?
      sequence << [move_x, move_y]
    end
    [[start_x, start_y], sequence]
  end
end

hp1 = HumanPlayer.new("Jack")
hp2 = HumanPlayer.new("Jill")
c = Checkers.new(hp1, hp2)
c.play
