require_relative 'base_object'

class Bill < BaseObject

  MaxLength = 52
  
  # define the data that goes in this object
  Members = [
    { name: "title",  type: String  },
    { name: "agenda", type: String  },
    { name: "sector", type: String  },
    { name: "vps",    type: Integer }
  ]

  def Bill.matchup_descriptions(bills_A, bills_B)
    bills_A.each_index.map do |index|
      "#{bills_A[index]}   opposite   #{bills_B[index]}"
    end
  end

  def to_s
    sprintf "%-29s %-12s %-7s #{vps}", title, agenda, sector
  end
  
end
