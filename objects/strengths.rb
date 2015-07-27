require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

class Strengths

  # define the data that goes in this object
  Members = [
    { name: :defense, type: Integer },
    { name: :economy, type: Integer },
    { name: :society, type: Integer }
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable
  
end
