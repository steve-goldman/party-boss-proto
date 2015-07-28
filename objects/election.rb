require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election

  # define the data that goes in this object
  Members = [
    { name: :state_of_the_union, type: StateOfTheUnion },
    { name: :office_holders,     type: OfficeHolder, is_array: true },
    { name: :candidates_A,       type: Politician,   is_array: true },
    { name: :candidates_B,       type: Politician,   is_array: true },
    { name: :allocation_A,       type: DiceAllocation },
    { name: :allocation_B,       type: DiceAllocation },
    { name: :outcomes_A,         type: DiceOutcome,  is_array: true },
    { name: :outcomes_B,         type: DiceOutcome,  is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def points_A(index)
    outcomes_A[index].sum + candidates_A[index].strength(state_of_the_union.priorities[0])
  end

  def points_B(index)
    outcomes_B[index].sum + candidates_B[index].strength(state_of_the_union.priorities[0])
  end

  def winner(index)
    get_winner candidates_A[index], points_A(index), candidates_B[index], points_B(index), office_holders[index].politician
  end

  def winning_team(index)
    winner(index) == candidates_A[index] ? 'A' : 'B'
  end

  def loser(index)
    winner(index) == candidates_A[index] ? candidates_B[index] : candidates_A[index]
  end

  private

  def get_winner(candidate_A, points_A, candidate_B, points_B, encumbent)
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
