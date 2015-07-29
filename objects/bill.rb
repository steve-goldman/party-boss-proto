require_relative 'base_object'

class Bill < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :title,  type: String  },
    { name: :agenda, type: String  },
    { name: :sector, type: String  },
    { name: :vps,    type: Integer }
  ]

  def to_s
    sprintf "%-29s %-12s %-7s #{vps}", title, agenda, sector
  end
  
end
