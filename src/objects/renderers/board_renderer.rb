require_relative 'renderer'
require_relative '../board'

class BoardRenderer < Renderer

  def initialize
    super([Politician::MaxLength, Bill::MaxLength].max)
  end
  
  @@instance = nil

  def BoardRenderer.get
    @@instance = BoardRenderer.new if @@instance.nil?
    @@instance
  end

  def render(board)
    [
      "The state of the union: #{board.state_of_the_union}", underline,
      party_header(board),     underline,
      office_holders(board),   underline,
      vps(board),              underline,
      passed_bills(board),     underline,
      fundraising_dice(board),
    ].join("\n")
  end

  def render_sunsetting_bills(board, next_cycle)
    [
      "Sunsetting bills",  underline,
      party_header(board), underline,
      sunsetting_bills(board, next_cycle),
    ].join("\n")
  end

  private

  def sunsetting_bills(board, next_cycle)
    num_a = board.sunsetting_bills_count(:A, next_cycle)
    num_b = board.sunsetting_bills_count(:B, next_cycle)
    [num_a, num_b].max.times.map { |index|
      two_sides(index < num_a ? board.passed_bills_A[index] : "",
                index < num_b ? board.passed_bills_B[index] : "")
    }.join("\n")
  end
  
  def office_holders(board)
    [
      "Politicians holding office",
      underline
    ]
      .concat(Config.get.seats_num.times.map { |index|
                two_sides(board.office_holders[index].party.to_sym == :A ? board.office_holders[index].politician : "",
                          board.office_holders[index].party.to_sym == :B ? board.office_holders[index].politician : "")})
      .join("\n")
  end

  def vps(board)
    [
      "Victory Points",
      underline,
      two_sides(board.vps_A, board.vps_B),
    ].join("\n")
  end
  
  def passed_bills(board)
    [
      "Passed bills",
      underline,
    ]
      .concat([board.passed_bills_A.count, board.passed_bills_B.count].max.times.map { |index|
                two_sides(board.passed_bills_A.count > index ? board.passed_bills_A[index] : "",
                               board.passed_bills_B.count > index ? board.passed_bills_B[index] : "")})
      .join("\n")
  end

  def fundraising_dice(board)
    [
      "Pending fundraising dice",
      underline,
      two_sides(board.fundraising_dice_A, board.fundraising_dice_B),
    ].join("\n")
  end
  
end
