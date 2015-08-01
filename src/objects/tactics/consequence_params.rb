require_relative '../base_object'
require_relative 'consequence'

class ConsequenceParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "who",          type: String,      can_be_nil: true },
    { name: "agenda",       type: String,      can_be_nil: true },
    { name: "how_many",     type: Integer,     can_be_nil: true },
    { name: "operator",     type: String,      can_be_nil: true },
    { name: "consequences", type: Consequence, is_array:   true },
  ]

end
