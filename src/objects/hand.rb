require_relative 'base_object'
require_relative 'politician'
require_relative 'bill'
require_relative 'tactics/tactic'

class Hand < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "politicians", type: Politician, is_array: true },
    { name: "bills",       type: Bill,       is_array: true },
    { name: "tactics",     type: Tactic,     is_array: true },
  ]
  
end
