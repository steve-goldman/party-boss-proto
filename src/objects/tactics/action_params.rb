require_relative '../base_object'

# forward declaration
class Action < BaseObject; end

class ActionParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "actions",          type: Action,       can_be_nil: true, is_array: true },
    { name: "who",              type: String,       can_be_nil: true },
    { name: "how_many",         type: Integer,      can_be_nil: true },
    { name: "how_many_dice",    type: Integer,      can_be_nil: true },
    { name: "all_but_how_many", type: Integer,      can_be_nil: true },
  ]

end
