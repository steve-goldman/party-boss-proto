require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "candidates_A",       type: Politician,   is_array: true },
    { name: "candidates_B",       type: Politician,   is_array: true },
    { name: "allocation_A",       type: DiceAllocation },
    { name: "allocation_B",       type: DiceAllocation },
    { name: "outcomes_A",         type: DiceOutcome,  is_array: true },
    { name: "outcomes_B",         type: DiceOutcome,  is_array: true },
  ]

  def get_result(index, board)
    winner = get_winner index, board

    {
      winner: winner,
      loser: winner == candidates_A[index] ? candidates_B[index] : candidates_A[index],
      winning_party: winner == candidates_A[index] ? 'A' : 'B',
      losing_party: winner == candidates_A[index] ? 'B' : 'A'
    }
  end

  def description(board)
    defeats = " DEFEATS "
    results_array = []
    Config.get.seats_num.times do |index|
      result = get_result index, board
      results_array << sprintf("%-#{Politician::MaxLength}s (party '%s') #{defeats} %-#{Politician::MaxLength}s (party '%s')",
                               result[:winner],
                               result[:winning_party],
                               result[:loser],
                               result[:losing_party])
      results_array << sprintf("%-#{Politician::MaxLength}s %s %-#{Politician::MaxLength}s",
                               breakdown_str(index, board, result[:winning_party]),
                               " " * ("(party 'x') #{defeats}".length),
                               breakdown_str(index, board, result[:losing_party]))
                               
    end

    [
      "Election results",
      ""
    ].concat(results_array).join("\n")
  end

  private
  
  def breakdown_str(index, board, party)
    "#{points(index, board, party)} = #{strength_points(index, board, party)} + #{outcomes(index, party)}"
  end

  def strength_points(index, board, party)
    party == 'A' ?
      candidates_A[index].strength(board.state_of_the_union.priorities[0]) :
      candidates_B[index].strength(board.state_of_the_union.priorities[0])
  end

  def outcomes(index, party)
    (send "outcomes_#{party}")[index]
  end

  def outcomes_points(index, party)
    outcomes(index, party).sum
  end

  def points(index, board, party)
    strength_points(index, board, party) + outcomes_points(index, party)
  end

  def get_winner(index, board)
    if points(index, board, 'A') > points(index, board, 'B')
      candidates_A[index]
    elsif points(index, board, 'A') < points(index, board, 'B')
      candidates_B[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[1]) >
          candidates_B[index].strength(board.state_of_the_union.priorities[1])
      candidates_A[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[1]) <
          candidates_B[index].strength(board.state_of_the_union.priorities[1])
      candidates_B[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[2]) >
          candidates_B[index].strength(board.state_of_the_union.priorities[2])
      candidates_A[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[2]) <
          candidates_B[index].strength(board.state_of_the_union.priorities[2])
      candidates_B[index]
    elsif candidates_A[index] == board.office_holders[index].politician
      candidates_A[index]
    else
      candidates_B[index]
    end
  end

end
