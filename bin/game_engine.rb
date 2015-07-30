require_relative '../objects/game'
require_relative '../objects/game_snapshot'
require_relative '../objects/election'
require_relative 'human_boss'
require_relative 'dice_roller'
require_relative 'logger'

class GameEngine

  def initialize(game = nil)
    if game.nil?
      @game_snapshot = GameSnapshot.new_game
      @game = Game.new(GameSnapshot.deserialize(@game_snapshot.serialize), [])
    else
      @game_snapshot = game.initial_game_snapshot
      @game = game
    end
    @boss_A = HumanBoss.new("A", @game_snapshot.hand_A)
    @boss_B = HumanBoss.new("B", @game_snapshot.hand_B)
    catch_up if !game.nil?
  end

  def catch_up
    @game.cycles.each_index do |index|
      Logger.subheader "Catch-up cycle #{index + 1} / #{@game.cycles.count}"
      Logger.header "Election phase"
      Logger.header @game_snapshot.board.description

      election = @game.cycles[index].election
      Election.log_matchups election.candidates_A, election.candidates_B
      election.remove_candidates_from_hands @game_snapshot
      election.put_winners_in_office @game_snapshot
      election.deal_politicians @game_snapshot
      election.put_losers_in_deck @game_snapshot

      Logger.header(election.description @game_snapshot.board)

      @game_snapshot.end_cycle @game.cycles[index].next_state_of_the_union
    end
  end
  
  def run(num_cycles)
    dice_roller = DiceRoller.new
    num_cycles.times do |index|
      Logger.subheader "Cycle #{index + 1} / #{num_cycles}"
      Logger.header "Election phase"
      election = Election.run_election @game_snapshot, @boss_A, @boss_B, dice_roller
      Logger.header "Legislative phase"
      @game_snapshot.end_cycle @game_snapshot.state_of_the_union_deck.shuffle!.pop
      @game.cycles << Cycle.new(election, @game_snapshot.board.state_of_the_union)
    end
    @game
  end

  private

end

engine = GameEngine.new(Game.from_file('input.json'))
#engine = GameEngine.new(nil)
engine.run((ARGV.shift || 1).to_i).to_file('output.json')
