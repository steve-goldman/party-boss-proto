require_relative '../base_object'
require_relative 'action'

class ActionParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "who",            type: String,  can_be_nil: true },
    { name: "agenda",         type: String,  can_be_nil: true },
    { name: "how_many",       type: Integer, can_be_nil: true },
    { name: "operator",       type: String,  can_be_nil: true },
    { name: "actions",        type: Action,  is_array:   true },
  ]

end
