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
    StateOfTheUnion.new([ "social", "economy", "defense" ]),
    StateOfTheUnion.new([ "social", "defense", "economy" ]),
    StateOfTheUnion.new([ "economy", "social", "defense" ]),
    StateOfTheUnion.new([ "economy", "defense", "social" ]),
    StateOfTheUnion.new([ "defense", "economy", "social" ]),
    StateOfTheUnion.new([ "defense", "social", "economy" ])
  ]

end
