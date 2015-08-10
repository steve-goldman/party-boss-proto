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

  def filibuster?
    return name.start_with? 'Filibuster'
  end

  def tabling_motion?
    return name.start_with? 'Tabling Motion'
  end

  def must_play_on_party(party)
    preconditions.each do |precondition|
      if precondition.precondition == 'played_on_party'
        other_party = party == :A ? :B : :A
        return precondition.params.who == 'self' ? party : other_party
      end
    end
    nil
  end

  Pass = Tactic.new("pass", [], [], [])

end
