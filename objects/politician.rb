require_relative 'base_object'
require_relative 'strengths'

class Politician < BaseObject

  private

  NameMaxLength = 18

  public

  MaxLength = NameMaxLength + 5 + Strengths::Length
  
  # define the data that goes in this object
  Members = [
    { name: "name",        type: String    },
    { name: "fundraising", type: Integer   },
    { name: "strengths",   type: Strengths }
  ]

  def strength(priority)
    strengths.send priority
  end

  def to_s
    sprintf "%-#{NameMaxLength}s f:#{fundraising} #{strengths}", name
  end
  
end
