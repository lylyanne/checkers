class InvalidMoveError < StandardError
end

class Piece
  BLACK_MOVES = [[1,1], [1, -1]]
  RED_MOVES = [[-1, 1], [-1,-1]]
  attr_reader :board, :color, :kinged
  attr_accessor :pos

  def initialize(board, color, pos, kinged = false)
    @board, @color, @pos = board, color, pos
    @kinged = kinged
  end

  def kinged?
    kinged
  end

  def at_back_row?
    row = pos.first
    color == :black ? row == 7 : row == 0
  end

  def maybe_promote
    @kinged = true if at_back_row?
  end

  def moves
    if kinged?
      BLACK_MOVES + RED_MOVES
    else
      color == :black ? BLACK_MOVES : RED_MOVES
    end
  end

  def perform_slide(end_pos)
    return false unless board.empty?(end_pos)

    possible_moves = moves.map do |move|
      [move[0] + pos[0], move[1] + pos[1]]
    end

    on_board_moves = possible_moves.select { |move| Board.onboard?(move) }

    return false unless on_board_moves.include?(end_pos)

    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self

    maybe_promote

    true
  end

  def perform_jump(end_pos)
    return false unless board.empty?(end_pos)

    possible_pos = moves.map do |move|
      [move[0] * 2 + pos[0], move[1] * 2 + pos[1]]
    end

    on_board_pos = possible_pos.select { |move| Board.onboard?(move) }

    return false unless on_board_pos.include?(end_pos)

    move_diff = [end_pos[0] - pos[0], end_pos[1] - pos[1]]
    move_diff = [move_diff[0] / 2, move_diff[1] / 2]

    pos_to_jumped_over = [pos[0] + move_diff[0], pos[1] + move_diff[1]]
    return false if board.empty?(pos_to_jumped_over) || board[pos_to_jumped_over].color == color

    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self

    board[pos_to_jumped_over] = nil

    maybe_promote

    true
  end

  def render
    if kinged?
      color == :black ? '♚' : '♔'
    else
      color == :black ? '☻' : '☺'
    end
  end

  def perform_moves!(move_sequence)
    if move_sequence.length < 1
      raise InvalidMoveError.new "Please provide at least 1 move"
    end

    if move_sequence.length == 1

      slide_status = board[pos].perform_slide(move_sequence[0])
      if slide_status == false
        jump_status = board[pos].perform_jump(move_sequence[0])
      end
      raise InvalidMoveError.new "Unable to slide or jump to #{move_sequence[0]}" if jump_status == false
    else
      move_sequence.each_with_index do |move, idx|
        current_move = move

        move_status = board[pos].perform_jump(current_move)
        raise InvalidMoveError.new "Unable to jump to #{current_move}" if move_status == false
        pos = current_move
      end
    end
  end

  def perform_moves(move_sequence)
    unless valid_move_seq?(move_sequence)
      raise InvalidMoveError.new "The sequence provided were invalid"
    end

    perform_moves!(move_sequence)
  end

  def possible_jump?
    possible_pos = moves.map do |move|
      [move[0] * 2 + pos[0], move[1] * 2 + pos[1]]
    end

    on_board_pos = possible_pos.select { |move| Board.onboard?(move) }

    empty_end_pos = on_board_pos.select { |pos| board.empty?(pos)}

    empty_end_pos.select do |end_pos|
      move_diff = [end_pos[0] - pos[0], end_pos[1] - pos[1]]
      move_diff = [move_diff[0] / 2, move_diff[1] / 2]
      pos_to_jumped_over = [pos[0] + move_diff[0], pos[1] + move_diff[1]]
      !board.empty?(pos_to_jumped_over) && board[pos_to_jumped_over].color != color
    end

    empty_end_pos.empty? ? false : true
  end

  def valid_move_seq?(move_sequence)
    duped_board = board.dup

    begin
      duped_board[pos].perform_moves!(move_sequence)
    rescue InvalidMoveError => e
      puts e.message
      false
    else
      true
    end
  end

end
