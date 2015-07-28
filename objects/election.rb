require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election

  # define the data that goes in this object
  Members = [
    { name: :state_of_the_union, type: StateOfTheUnion },
    { name: :candidates_A,       type: Politician, is_array: true },
    { name: :candidates_B,       type: Politician, is_array: true },
    { name: :allocation_A,       type: DiceAllocation },
    { name: :allocation_B,       type: DiceAllocation },
    { name: :outcomes_A,         type: DiceOutcome, is_array: true },
    { name: :outcomes_B,         type: DiceOutcome, is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def points_A(index)
    outcomes_A[index].sum + candidates_A[index].strengths.send(state_of_the_union.priorities[0])
  end

  def points_B(index)
    outcomes_B[index].sum + candidates_B[index].strengths.send(state_of_the_union.priorities[0])
  end

  def winner(index)
    if points_A(index) > points_B(index)
      candidates_A[index]
    elsif points_A(index) < points_B(index)
      candidates_B[index]
    else
      nil
    end
  end
  
end
