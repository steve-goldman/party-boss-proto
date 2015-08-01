require_relative '../base_object'

class Params < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "who",      type: String, can_be_nil: true },
    { name: "agenda",   type: String, can_be_nil: true },
    { name: "how_many", type: String, can_be_nil: true },
    { name: "operator", type: String, can_be_nil: true },
  ]

end
