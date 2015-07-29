require_relative 'base_object'

class Strengths < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :defense, type: Integer },
    { name: :economy, type: Integer },
    { name: :society, type: Integer }
  ]

  def to_s
    "[d:#{defense},e:#{economy},s:#{society}]"
  end
  
end
