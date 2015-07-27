require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'strengths'

class Politician

  # define the data that goes in this object
  Members = [
    { name: :name,        type: String    },
    { name: :fundraising, type: Integer   },
    { name: :strengths,   type: Strengths }
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def to_s
    "(#{name}:#{fundraising},#{strengths})"
  end
  
end
