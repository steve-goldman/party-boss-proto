class Renderer

  def initialize(side_length)
    @side_length = side_length
    @length = 2 * side_length + 3
  end

  def party_header(board)
    a = "Party A#{board.tactics_lead_party == 'A' ? '*' : ''}"
    b = "Party B#{board.tactics_lead_party == 'B' ? '*' : ''}"
    two_sides a, b
  end

  def underline
    "-" * @length
  end

  def two_sides(left, right)
    sprintf("%-#{@side_length}s | %-#{@side_length}s", left, right)
  end
  

end
