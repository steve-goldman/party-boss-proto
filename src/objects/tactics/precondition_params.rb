require_relative '../base_object'

# forward declaration
class Precondition < BaseObject; end

class PreconditionParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "who",           type: String,       can_be_nil: true },
    { name: "agenda",        type: String,       can_be_nil: true },
    { name: "how_many",      type: Integer,      can_be_nil: true },
    { name: "operator",      type: String,       can_be_nil: true },
    { name: "preconditions", type: Precondition, can_be_nil: true, is_array: true },
  ]

end
