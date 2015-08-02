require_relative '../base_object'
require_relative 'tactic'

class PlayedTactic < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "party_played_by", type: String, can_be_nil: true },
    { name: "party_played_on", type: String, can_be_nil: true },
    { name: "bill_A",          type: Bill,   can_be_nil: true },
    { name: "bill_B",          type: Bill,   can_be_nil: true },
    { name: "tactic",          type: Tactic },
    { name: "drawn_tactics",   type: Tactic, is_array: true, can_be_nil: true },
  ]

end
