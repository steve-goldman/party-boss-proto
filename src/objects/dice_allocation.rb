require_relative 'base_object'

class DiceAllocation < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "counts", type: Integer, is_array: true },
  ]

  def to_s
    "#{counts}"
  end

  def sum
    counts.reduce(0, :+)
  end

  def clone
    DiceAllocation.new counts.clone
  end
  
end
