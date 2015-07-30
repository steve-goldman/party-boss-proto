require_relative 'base_object'
require_relative 'election'
require_relative 'legislative_session'

class Cycle < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "election",                type: Election           },
    { name: "legislative_session",     type: LegislativeSession },
    { name: "next_state_of_the_union", type: StateOfTheUnion    },
  ]
  
end
