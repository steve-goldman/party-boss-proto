require_relative 'base_object'
require_relative 'election'

class Cycle < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "election", type: Election },
  ]
  
end
