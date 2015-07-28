require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'state_of_the_union'
require_relative 'office_holder'

class Board

  # define the data that goes in this object
  Members = [
    { name: :state_of_the_union, type: StateOfTheUnion },
    { name: :office_holders,     type: OfficeHolder, is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable
  
end
