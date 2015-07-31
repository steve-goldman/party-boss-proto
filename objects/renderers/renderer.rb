class Renderer

  def initialize(side_length)
    @side_length = side_length
    @length = 2 * side_length + 3
  end

  def desc_party_header
    desc_two_sides 'Party A', 'Party B'
  end

  def underline
    "-" * @length
  end

  def desc_two_sides(left, right)
    sprintf("%-#{@side_length}s | %-#{@side_length}s", left, right)
  end
  

end
