require_relative '../objects/game_snapshot'
require_relative '../objects/election'

class GameEngine

  def initialize(game_snapshot, player_A, player_B, dice_roller)
    @game_snapshot = game_snapshot
    @player_A = player_A
    @player_B = player_B
    @dice_roller = dice_roller
  end

  def run_election
    candidates_A = @player_A.get_candidates(@game_snapshot)
    candidates_B = @player_B.get_candidates(@game_snapshot)
    allocation_A = @player_A.get_allocation(@game_snapshot, candidates_A)
    allocation_B = @player_B.get_allocation(@game_snapshot, candidates_B)
    outcomes_A = @dice_roller.get_outcomes(allocation_A)
    outcomes_B = @dice_roller.get_outcomes(allocation_B)
    Election.new(candidates_A, candidates_B, allocation_A, allocation_B, outcomes_A, outcomes_B)
  end
  
end
