require_relative '../objects/game'
require_relative '../objects/game_snapshot'
require_relative '../objects/election'
require_relative '../objects/renderers/board_renderer'
require_relative '../objects/renderers/election_renderer'
require_relative '../objects/renderers/legislative_session_renderer'
require_relative '../objects/renderers/hand_renderer'
require_relative 'human_boss'
require_relative 'dice_roller'
require_relative 'logger'

class GameEngine

  def initialize(game = nil)
    if game.nil?
      @game_snapshot = GameSnapshot.new_game
      @game = Game.new(GameSnapshot.deserialize(@game_snapshot.serialize), [], nil)
    else
      @game_snapshot = game.initial_game_snapshot
      game.initial_game_snapshot = GameSnapshot.deserialize(@game_snapshot.serialize)
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
      Logger.header(BoardRenderer.get.render @game_snapshot.board)

      election = @game.cycles[index].election
      Logger.header(ElectionRenderer.get.render_matchups election.candidates_A,
                                                         election.candidates_B)

      @game_snapshot.apply_election(election, true)
      Logger.header(ElectionRenderer.get.render election, @game_snapshot.board)
      
      Logger.header "Legislative phase"
      Logger.header(BoardRenderer.get.render @game_snapshot.board)

      legislative_session = @game.cycles[index].legislative_session
      Logger.header(
        LegislativeSessionRenderer.get.render_bills_on_floor legislative_session.bills_A,
                                                             legislative_session.bills_B)

      @game_snapshot.apply_legislative_session(legislative_session, true)
      Logger.header(LegislativeSessionRenderer.get.render legislative_session,
                                                          @game_snapshot.board)
      
      @game_snapshot.end_cycle(@game.cycles[index], true)
    end
    # error checking
    raise "caught up snapshot disagrees with game state" if
      !@game.final_game_snapshot.equals?(@game_snapshot)
  end
  
  def run(num_cycles)
    Logger.subheader "The game is beginning"

    # show the initial hands
    ['A', 'B'].each do |party|
      Logger.header("Party '#{party}'s hand")
      Logger.header(HandRenderer.get.render @game_snapshot.send("hand_#{party}"))
    end
    
    dice_roller = DiceRoller.new
    num_cycles.times do |index|
      Logger.subheader "Cycle #{index + 1} / #{num_cycles}"

      Logger.header "Election phase"
      Logger.header(BoardRenderer.get.render @game_snapshot.board)

      election = Election.run_election(@game_snapshot,
                                       @boss_A, @boss_B,
                                       dice_roller)

      Logger.header(ElectionRenderer.get.render election, @game_snapshot.board)      

      Logger.header "Legislative phase"
      Logger.header(BoardRenderer.get.render @game_snapshot.board)

      legislative_session = LegislativeSession.run_session(@game_snapshot,
                                                           @boss_A, @boss_B,
                                                           dice_roller)

      Logger.header(LegislativeSessionRenderer.get.render legislative_session,
                                                          @game_snapshot.board)

      cycle = Cycle.new(election, legislative_session, nil)  # gs fills in SOTU
      @game_snapshot.end_cycle(cycle, false)
      @game.cycles.push cycle
    end
    # display the board once more for good measure
    Logger.header(BoardRenderer.get.render @game_snapshot.board)
    Logger.subheader "Game over"
    
    @game.final_game_snapshot = @game_snapshot
    @game
  end

  private

end

engine = GameEngine.new(Game.from_file('input.json'))
#engine = GameEngine.new(nil)
engine.run((ARGV.shift || 1).to_i).to_file('output.json')
