require_relative '../base_object'

# forward declaration
class Action < BaseObject; end

class ActionParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "which",            type: String,       can_be_nil: true },
    { name: "how_many",         type: Integer,      can_be_nil: true },
    { name: "how_many_dice",    type: Integer,      can_be_nil: true },
    { name: "all_but_how_many", type: Integer,      can_be_nil: true },
    { name: "description",      type: String,       can_be_nil: true },
    { name: "precondition",     type: Precondition, can_be_nil: true },
    { name: "actions",          type: Action,       can_be_nil: true, is_array: true },
  ]

end
