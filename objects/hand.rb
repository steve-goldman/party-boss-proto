require_relative 'base_object'
require_relative 'politician'

class Hand < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :politicians, type: Politician, is_array: true },
  ]
  
end
