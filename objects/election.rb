require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election

  # define the data that goes in this object
  Members = [
    { name: :candidates_A, type: Politician, is_array: true },
    { name: :candidates_B, type: Politician, is_array: true },
    { name: :allocation_A, type: DiceAllocation },
    { name: :allocation_B, type: DiceAllocation },
    { name: :outcomes_A,   type: DiceOutcome, is_array: true },
    { name: :outcomes_B,   type: DiceOutcome, is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable
  
end
