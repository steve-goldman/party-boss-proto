require_relative '../base_object'

class Tactic < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "name",          type: String                       },
    { name: "preconditions", type: Precondition, is_array: true },
    { name: "actions",       type: Action,       is_array: true },
    { name: "consequences",  type: Consequence,  is_array: true },
  ]

end
