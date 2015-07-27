require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'politician'

class OfficeHolder

  # define the data that goes in this object
  Members = [
    { name: :team,       type: String     },
    { name: :politician, type: Politician },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable
  
end
