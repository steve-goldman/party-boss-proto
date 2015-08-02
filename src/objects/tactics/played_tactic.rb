require_relative '../base_object'
require_relative 'tactic'

class PlayedTactic < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "party_played_by", type: String },
    { name: "party_played_on", type: String },
    { name: "bill_A",          type: Bill   },
    { name: "bill_B",          type: Bill   },
    { name: "tactic",          type: Tactic },
  ]

end
