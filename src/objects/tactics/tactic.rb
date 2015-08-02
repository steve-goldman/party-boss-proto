require_relative '../base_object'
require_relative 'precondition'
require_relative 'action'
require_relative 'consequence'

class Tactic < BaseObject

  MaxLength = 24

  # define the data that goes in this object
  Members = [
    { name: "name",          type: String                       },
    { name: "preconditions", type: Precondition, is_array: true },
    { name: "actions",       type: Action,       is_array: true },
    { name: "consequences",  type: Consequence,  is_array: true },
  ]

  def to_s
    name
  end

  def can_play(party, played_on_party, bill_A, bill_B, board)
    preconditions
      .select { |precondition| !precondition.holds(party, played_on_party, bill_A, bill_B, board) }
      .empty?
  end

  Pass = Tactic.new("pass", [], [], [])

end
