require_relative '../base_object'

# forward declaration
class Action < BaseObject; end

class ActionParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "actions", type: Action, can_be_nil: true, is_array: true },
  ]

end
