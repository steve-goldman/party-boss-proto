require_relative 'base_object'
require_relative 'game_state'
require_relative 'cycle'

class Game < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "initial_game_state", type: GameState             },
    { name: "cycles",             type: Cycle, is_array: true },
    { name: "final_game_state",   type: GameState             },
  ]
  
end
