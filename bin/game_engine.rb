require_relative '../objects/game'
require_relative '../objects/game_snapshot'
require_relative '../objects/election'
require_relative 'human_boss'
require_relative 'dice_roller'
require_relative 'logger'

class GameEngine

  def run(num_cycles)
    game_snapshot = GameSnapshot.new_game
    boss_A = HumanBoss.new("A", game_snapshot.hand_A)
    boss_B = HumanBoss.new("B", game_snapshot.hand_B)
    dice_roller = DiceRoller.new
    game = Game.new(GameSnapshot.deserialize(game_snapshot.serialize), [])
    
    num_cycles.times do |index|
      Logger.subheader "Cycle #{index + 1} / #{num_cycles}"
      Logger.header "Election phase"
      election = Election.run_election game_snapshot, boss_A, boss_B, dice_roller
      game_snapshot.apply_election election
      Logger.header "Legislative phase"
      game.cycles << Cycle.new(election)
      game_snapshot.end_cycle
    end
    game
  end

  private

end

GameEngine.new.run (ARGV.shift || 1).to_i
