require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

class DiceOutcome

  # define the data that goes in this object
  Members = [
    { name: :rolls, type: Integer, is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def sum
    rolls.reduce(0) { |sum, roll| sum + roll }
  end

  def to_s
    "#{sum}:#{rolls}"
  end
  
end
