require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

class BaseObject

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

end
