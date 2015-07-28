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
    Logger.header("Election matchups").indent
    candidates_A.each_index do |index|
      Logger.log "#{candidates_A[index]} versus #{candidates_B[index]}"
    end
    Logger.unindent
    Logger.header("Player 'A' choosing dice allocation").indent
    allocation_A = @player_A.get_allocation(@game_snapshot, candidates_A, candidates_B)
    Logger.unindent
    Logger.header("Player 'B' choosing dice allocation").indent
    allocation_B = @player_B.get_allocation(@game_snapshot, candidates_B, candidates_A)
    Logger.unindent
    election = Election.new(@game_snapshot.board.state_of_the_union,
                            @game_snapshot.board.office_holders,
                            candidates_A,
                            candidates_B,
                            allocation_A,
                            allocation_B,
                            @dice_roller.get_outcomes(allocation_A),
                            @dice_roller.get_outcomes(allocation_B))
    Logger.header("Election results").indent
    election.candidates_A.each_index do |index|
      Logger.subheader "#{candidates_A[index]} versus #{candidates_B[index]}"
      Logger.log "'A' rolled #{election.outcomes_A[index]} for total of #{election.points_A index}"
      Logger.log "'B' rolled #{election.outcomes_B[index]} for total of #{election.points_B index}"
      Logger.log "#{election.winner index} wins!"
    end
    Logger.unindent
  end
  
end

GameEngine.new_game.start
