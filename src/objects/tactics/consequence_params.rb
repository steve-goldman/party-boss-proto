require_relative '../base_object'

# forward declaration
class Consequence < BaseObject; end

class ConsequenceParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "which",         type: String,       can_be_nil: true },
    { name: "how_many",      type: Integer,      can_be_nil: true },
    { name: "preconditions", type: Precondition, can_be_nil: true, is_array: true },
  ]

end
