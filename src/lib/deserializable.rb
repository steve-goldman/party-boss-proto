require 'json'

module Deserializable

  # Requires the class mixing this in defines a constant `Members',
  # which is an array of hashes with member `name' and `type'.
  #
  # Provides a class method `deserialize', assuming that all types are
  # either `String', `Int', or another class that mixes in this module
  #
  # Provides a class method `from_file', which reads the serialized
  # class from a JSON file.

  def deserialize(hash)
    self.send(:new, *self::Members.map { |member|
                if !hash[member[:name]].nil? || !member[:can_be_nil]
                  if member[:is_array]
                    hash[member[:name]].map do |value|
                      deserialize_member(member[:type], value)
                    end
                  else
                    deserialize_member(member[:type], hash[member[:name]])
                  end
                end
              })
  end

  def from_file(filename)
    deserialize JSON.parse(File.read(filename))
  end

  def from_array_file(filename)
    JSON.parse(File.read(filename)).map do |record|
      deserialize record
    end
  end

  private

  def deserialize_member(type, value)
    if type == String || type == Integer
      value
    else
      type.send(:deserialize, value)
    end
  end
end
