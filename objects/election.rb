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

  def points_A(index, state_of_the_union)
    outcomes_A[index].sum + candidates_A[index].strength(state_of_the_union.priorities[0])
  end

  def points_B(index, state_of_the_union)
    outcomes_B[index].sum + candidates_B[index].strength(state_of_the_union.priorities[0])
  end

  def winner(index, state_of_the_union, office_holders)
    get_winner state_of_the_union,
               candidates_A[index],
               points_A(index, state_of_the_union),
               candidates_B[index],
               points_B(index, state_of_the_union),
               office_holders[index].politician
  end

  def winning_team(index, state_of_the_union, office_holders)
    winner(index, state_of_the_union, office_holders) == candidates_A[index] ? 'A' : 'B'
  end

  def loser(index, state_of_the_union, office_holders)
    winner(index, state_of_the_union, office_holders) == candidates_A[index] ? candidates_B[index] : candidates_A[index]
  end

  private

  def get_winner(state_of_the_union, candidate_A, points_A, candidate_B, points_B, encumbent)
    if points_A > points_B
      candidate_A
    elsif points_A < points_B
      candidate_B
    elsif candidate_A.strength(state_of_the_union.priorities[1]) >
          candidate_B.strength(state_of_the_union.priorities[1])
      candidate_A
    elsif candidate_A.strength(state_of_the_union.priorities[1]) <
          candidate_B.strength(state_of_the_union.priorities[1])
      candidate_B
    elsif candidate_A.strength(state_of_the_union.priorities[2]) >
          candidate_B.strength(state_of_the_union.priorities[2])
      candidate_A
    elsif candidate_A.strength(state_of_the_union.priorities[2]) <
          candidate_B.strength(state_of_the_union.priorities[2])
      candidate_B
    elsif candidate_A == encumbent
      candidate_A
    else
      candidate_B
    end
  end
                                       
end
