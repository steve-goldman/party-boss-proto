require_relative 'base_object'

class DiceAllocation < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "counts", type: Integer, is_array: true },
  ]

  def to_s
    "#{counts}"
  end
  
end