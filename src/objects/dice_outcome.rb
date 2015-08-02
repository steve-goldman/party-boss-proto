require_relative 'base_object'

class DiceOutcome < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "rolls", type: Integer, is_array: true },
  ]

  def sum
    rolls.reduce(0, :+)
  end

  def to_s
    "#{sum}:#{rolls}"
  end
  
end
