require_relative '../base_object'

# forward declaration
class Consequence < BaseObject; end

class ConsequenceParams < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "consequences", type: Consequence, can_be_nil: true, is_array: true },
  ]

end
