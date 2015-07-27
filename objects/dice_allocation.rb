require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

class DiceAllocation

  # define the data that goes in this object
  Members = [
    { name: :counts, type: Integer, is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def to_s
    "#{counts}"
  end
  
end
