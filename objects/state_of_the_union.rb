require_relative 'base_object'

class StateOfTheUnion < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :priorities, type: String, is_array: true },
  ]

  def StateOfTheUnion.random
    States[Random.new.rand States.count]
  end

  def to_s
    "#{priorities[0]} => #{priorities[1]} => #{priorities[2]}"
  end

  private

  States = [
    StateOfTheUnion.new([ "society", "economy", "defense" ]),
    StateOfTheUnion.new([ "society", "defense", "economy" ]),
    StateOfTheUnion.new([ "economy", "society", "defense" ]),
    StateOfTheUnion.new([ "economy", "defense", "society" ]),
    StateOfTheUnion.new([ "defense", "economy", "society" ]),
    StateOfTheUnion.new([ "defense", "society", "economy" ])
  ]

end
