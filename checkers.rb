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
    puts "#{turn_colors.key(:red).name} is red"
    puts "#{turn_colors.key(:black).name} is black"
    until board.over?
      system "clear"
      begin

        puts "#{turn_colors[players[0]].to_s}'s turn"
        puts board.render
        start, sequence = players[0].play_turn(board, turn_colors[players[0]])
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

  def play_turn(board, msg)
    status = true
    while(status)
      status = board.cursor_loop(msg)
    end
    start = board.sequence.shift
    sequence = board.sequence
    board.sequence = []
    [start, sequence]
  end
end

class ComputerPlayer
  attr_reader :name

  def initialize(name = "computer")
    @name = name
  end

  def play_turn(board, color)
    color_pieces = board.pieces.select { |piece| piece.color == color }
    enemy_pieces = board.pieces.select { |piece| piece.color != color }

    color_pieces.each do |my_piece|
      enemy_pieces.each do |enemy_piece|
        diff = [enemy_piece.pos[0] - my_piece.pos[0], enemy_piece.pos[1] - my_piece.pos[1]]
        if my_piece.moves.include?(diff)
          jump_to = [my_piece.pos[0] + diff[0] * 2, my_piece.pos[1] + diff[1] * 2]
          return [my_piece.pos, [jump_to] ] if Board.onboard?(jump_to) && board[jump_to].nil?
        end
      end
    end

    start = color_pieces.sample
    start_moves = start.moves

    end_pos = start_moves.map do |move|
      [start.pos[0] + move[0], start.pos[1] + move[1]]
    end.select { |move| Board.onboard?(move) }

    [start.pos, [end_pos.sample]]
  end
end

hp1 = HumanPlayer.new("Jack")
#hp2 = HumanPlayer.new("Jill")
cp1 = ComputerPlayer.new
c = Checkers.new(hp1, cp1)
c.play
