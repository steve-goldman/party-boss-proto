require_relative '../base_object'

class Params < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "who",      type: String },
    { name: "agenda",   type: String },
    { name: "how_many", type: String },
    { name: "operator", type: String },
  ]

end
