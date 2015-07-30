require_relative '../objects/game'
require_relative '../objects/game_snapshot'
require_relative '../objects/election'
require_relative 'human_boss'
require_relative 'dice_roller'
require_relative 'logger'

class GameEngine

  def initialize(game_snapshot, boss_A, boss_B, dice_roller)
    @game_snapshot = game_snapshot
    @boss_A = boss_A
    @boss_B = boss_B
    @dice_roller = dice_roller
    @game = Game.new(GameSnapshot.deserialize(@game_snapshot.serialize), [])
  end

  def GameEngine.new_game
    game_snapshot = GameSnapshot.new_game
    GameEngine.new(game_snapshot,
                   HumanBoss.new("A", game_snapshot.hand_A),
                   HumanBoss.new("B", game_snapshot.hand_B),
                   DiceRoller.new)
  end

  def run(num_cycles)
    num_cycles.times do |index|
      Logger.subheader "Cycle #{index + 1} / #{num_cycles}"
      Logger.header "Election phase"
      election = run_election
      @game_snapshot.apply_election election
      Logger.header "Legislative phase"
      @game.cycles << Cycle.new(election)
      @game_snapshot.end_cycle
    end
    @game
  end

  private

end

GameEngine.new_game.run (ARGV.shift || 1).to_i
