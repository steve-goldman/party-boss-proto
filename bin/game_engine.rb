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
  end

  def GameEngine.new_game
    game_snapshot = GameSnapshot.new_game
    GameEngine.new(game_snapshot,
                   HumanBoss.new("A", game_snapshot.hand_A),
                   HumanBoss.new("B", game_snapshot.hand_B),
                   DiceRoller.new)
  end

  def start(num_cycles)
    num_cycles.times do
      Logger.header "Election phase"
      @game_snapshot.apply_election run_election
      Logger.header "Legislative phase"
      @game_snapshot.board.state_of_the_union = StateOfTheUnion.next
    end
  end

  private

  def run_election
    Logger.header @game_snapshot.board.description
    Logger.header("Boss 'A' choosing candidates").indent
    candidates_A = @boss_A.get_candidates(@game_snapshot)
    Logger.unindent
    Logger.header("Boss 'B' choosing candidates").indent
    candidates_B = @boss_B.get_candidates(@game_snapshot)
    Logger.unindent
    Logger.header("Election matchups").indent
    Config.get.seats_num.times do |index|
      Logger.log "#{candidates_A[index]} versus #{candidates_B[index]}"
    end
    Logger.unindent
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = @boss_A.get_allocation(@game_snapshot, candidates_A, candidates_B)
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = @boss_B.get_allocation(@game_snapshot, candidates_B, candidates_A)
    Logger.unindent
    election = Election.new(candidates_A,
                            candidates_B,
                            allocation_A,
                            allocation_B,
                            @dice_roller.get_outcomes(allocation_A),
                            @dice_roller.get_outcomes(allocation_B))
    Logger.header(election.description @game_snapshot.board).indent
    Logger.unindent
    election
  end
  
end

GameEngine.new_game.start 1
