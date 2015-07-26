require 'json'

module Serializable

  # Requires the class mixing this in defines a constant `Members',
  # which is an array of hashes with member `name' and `type'.
  #
  # Provides `serialize', assuming that all types are either `String',
  # `Integer', another class that mixes in this module, or an array
  # of any of these things, by optionally setting is_array.
  #
  # Provides `to_file', which writes the serialized class to file as
  # JSON.

  def serialize
    hash = {}
    self.class::Members.each do |member|
      if member[:is_array]
        hash[member[:name]] = self.send(member[:name]).map do |value|
          serialize_member(member[:type], value)
        end
      else
        hash[member[:name]] = serialize_member(member[:type], self.send(member[:name]))
      end
    end
    hash
  end

  def to_file(filename)
    File.open(filename, "w") do |file|
      file.write(JSON.pretty_generate(serialize) + "\n")
    end
  end

  private

  def serialize_member(type, value)
    if type == String || type == Integer
      value
    else
      value.serialize
    end
  end
  
end
