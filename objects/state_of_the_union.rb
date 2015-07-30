require_relative 'base_object'

class StateOfTheUnion < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "issue",      type: String },
    { name: "priorities", type: String, is_array: true },
  ]

  @@state_of_the_unions = nil

  def StateOfTheUnion.next
    @@state_of_the_unions = StateOfTheUnion.from_array_file('data/state_of_the_unions.json') if @@state_of_the_unions.nil?
    @@state_of_the_unions.shuffle[0]
  end

  def to_s
    "#{issue} (#{priorities[0]} => #{priorities[1]} => #{priorities[2]})"
  end

end
