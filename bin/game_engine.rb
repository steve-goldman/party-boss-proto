require_relative '../objects/game_snapshot'
require_relative '../objects/election'
require_relative 'manual_player'
require_relative 'dice_roller'
require_relative 'logger'

class GameEngine

  def initialize(game_snapshot, player_A, player_B, dice_roller)
    @game_snapshot = game_snapshot
    @player_A = player_A
    @player_B = player_B
    @dice_roller = dice_roller
  end

  def GameEngine.new_game
    game_snapshot = GameSnapshot.new_game
    GameEngine.new(game_snapshot,
                   ManualPlayer.new("A", game_snapshot.hand_A),
                   ManualPlayer.new("B", game_snapshot.hand_B),
                   DiceRoller.new)
  end

  def start
    run_election
  end

  private

  def run_election
    Logger.header "The state of the union is #{@game_snapshot.board.state_of_the_union}"
    Logger.header("Player 'A' choosing candidates").indent
    candidates_A = @player_A.get_candidates(@game_snapshot)
    Logger.unindent
    Logger.header("Player 'B' choosing candidates").indent
    candidates_B = @player_B.get_candidates(@game_snapshot)
    Logger.unindent
    puts "player 'A' choosing dice allocation"
    allocation_A = @player_A.get_allocation(@game_snapshot, candidates_A)
    puts "player 'B' choosing dice allocation"
    allocation_B = @player_B.get_allocation(@game_snapshot, candidates_B)
    puts "rolling dice"
    outcomes_A = @dice_roller.get_outcomes(allocation_A)
    puts "player 'A' rolled #{outcomes_A}"
    outcomes_B = @dice_roller.get_outcomes(allocation_B)
    puts "player 'B' rolled #{outcomes_B}"
    Election.new(candidates_A, candidates_B, allocation_A, allocation_B, outcomes_A, outcomes_B)
  end
  
end

GameEngine.new_game.start
