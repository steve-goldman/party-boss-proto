require_relative '../base_object'

class Action < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "action", type: String },
    { name: "params", type: Params },
  ]

end
