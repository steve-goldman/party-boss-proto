require_relative 'base_object'
require_relative 'politician'

class OfficeHolder < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "party",      type: String     },
    { name: "politician", type: Politician },
  ]
  
end
