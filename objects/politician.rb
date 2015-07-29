require_relative 'base_object'
require_relative 'strengths'

class Politician < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :name,        type: String    },
    { name: :fundraising, type: Integer   },
    { name: :strengths,   type: Strengths }
  ]

  def strength(priority)
    strengths.send priority
  end

  def to_s
    sprintf "%-18s f:#{fundraising} #{strengths}", name
  end
  
end
