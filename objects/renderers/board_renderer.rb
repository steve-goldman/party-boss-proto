require_relative '../board'

class BoardRenderer

  def BoardRenderer.render(board)
    [
      "The state of the union: #{board.state_of_the_union}", underline,
      BoardRenderer.desc_party_header,          underline,
      desc_office_holders(board), underline,
      desc_vps(board),            underline,
      desc_passed_bills(board),   underline,
    ].join("\n")
  end

  private
  
  DescSideLength = [Politician::MaxLength, Bill::MaxLength].max
  DescLength = 2 * DescSideLength + 3

  def BoardRenderer.desc_office_holders(board)
    [
      "Politicians holding office",
      underline
    ]
      .concat(Config.get.seats_num.times.map { |index|
                desc_two_sides(board.office_holders[index].party == 'A' ? board.office_holders[index].politician : "",
                               board.office_holders[index].party == 'B' ? board.office_holders[index].politician : "")})
      .join("\n")
  end

  def BoardRenderer.desc_vps(board)
    [
      "Victory Points",
      underline,
      desc_two_sides(board.vps_A, board.vps_B),
    ].join("\n")
  end
  
  def BoardRenderer.desc_passed_bills(board)
    [
      "Passed bills",
      underline,
    ]
      .concat([board.passed_bills_A.count, board.passed_bills_B.count].max.times.map { |index|
                desc_two_sides(board.passed_bills_A.count > index ? board.passed_bills_A[index] : "",
                               board.passed_bills_B.count > index ? board.passed_bills_B[index] : "")})
      .join("\n")
  end

  def BoardRenderer.desc_party_header
    desc_two_sides 'Party A', 'Party B'
  end

  def BoardRenderer.underline
    "-" * DescLength
  end

  def BoardRenderer.desc_two_sides(left, right)
    sprintf("%-#{DescSideLength}s | %-#{DescSideLength}s", left, right)
  end
  
end
