require_relative 'base_object'

class StateOfTheUnion < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "issue",      type: String },
    { name: "priorities", type: String, is_array: true },
  ]

  def to_s
    "#{issue} (#{priorities[0]} => #{priorities[1]} => #{priorities[2]})"
  end

  def to_short_s
    "#{priorities[0][0]}#{priorities[1][0]}#{priorities[2][0]}"
  end

end
