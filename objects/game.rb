require_relative 'base_object'
require_relative 'game_snapshot'
require_relative 'cycle'

class Game < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "initial_game_snapshot", type: GameSnapshot },
    { name: "cycles",                type: Cycle, is_array: true },
  ]
  
end
