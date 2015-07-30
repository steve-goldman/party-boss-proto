require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :candidates_A,       type: Politician,   is_array: true },
    { name: :candidates_B,       type: Politician,   is_array: true },
    { name: :allocation_A,       type: DiceAllocation },
    { name: :allocation_B,       type: DiceAllocation },
    { name: :outcomes_A,         type: DiceOutcome,  is_array: true },
    { name: :outcomes_B,         type: DiceOutcome,  is_array: true },
  ]

  def points_A(index, board)
    outcomes_A[index].sum + candidates_A[index].strength(board.state_of_the_union.priorities[0])
  end

  def points_B(index, board)
    outcomes_B[index].sum + candidates_B[index].strength(board.state_of_the_union.priorities[0])
  end

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
    results_array = []
    Config.get.seats_num.times do |index|
      result = get_result index, board
      results_array << sprintf("%-#{Politician::MaxLength}s (party '%s')  DEFEATS  %-#{Politician::MaxLength}s (party '%s')",
                               result[:winner],
                               result[:winning_party],
                               result[:loser],
                               result[:losing_party])
    end

    [
      "Election results",
      ""
    ].concat(results_array).join("\n")
  end

  private

  def get_winner(index, board)
    if points_A(index, board) > points_B(index, board)
      candidates_A[index]
    elsif points_A(index, board) < points_B(index, board)
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
