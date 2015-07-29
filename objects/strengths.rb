require_relative 'base_object'

class Strengths < BaseObject

  Length = 13
  
  # define the data that goes in this object
  Members = [
    { name: :defense, type: Integer },
    { name: :economy, type: Integer },
    { name: :social, type: Integer }
  ]

  def to_s
    "[d:#{defense},e:#{economy},s:#{social}]"
  end
  
end
