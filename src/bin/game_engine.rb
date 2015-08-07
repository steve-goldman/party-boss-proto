require 'optparse'
require 'tempfile'
require_relative '../objects/game'
require_relative '../objects/game_state'
require_relative '../objects/election'
require_relative '../objects/renderers/board_renderer'
require_relative '../objects/renderers/election_renderer'
require_relative '../objects/renderers/legislative_session_renderer'
require_relative '../objects/renderers/hand_renderer'
require_relative 'human_boss'
require_relative 'random_boss'
require_relative 'dice_roller'
require_relative 'logger'

class GameEngine

  def initialize(options)
    if options[:input_file].nil?
      @game_state = GameState.new_game
      @game = Game.new(Config.get, GameState.deserialize(@game_state.serialize), [], nil)
    else
      game = Game.from_file(options[:input_file])
      Config.get(game.config)
      @game_state = game.initial_game_state
      game.initial_game_state = GameState.deserialize(@game_state.serialize)
      @game = game
    end
    @boss_A = make_boss(:A, options[:boss_A])
    @boss_B = make_boss(:B, options[:boss_B])
    @num_catchup_cycles = @game.cycles.count
  end

  def catch_up
    @game.cycles.each_index do |index|
      Logger.subheader "Catch-up cycle #{index + 1} / #{@num_catchup_cycles}"

      Logger.header "Election phase"
      Logger.header(BoardRenderer.get.render @game_state.board)

      election = @game.cycles[index].election
      Logger.header(ElectionRenderer.get.render_matchups(@game_state.board,
                                                         election.candidates_A,
                                                         election.candidates_B))

      @game_state.apply_election(election, true)
      Logger.header(ElectionRenderer.get.render election, @game_state.board)
      
      Logger.header "Legislative phase"
      Logger.header(BoardRenderer.get.render @game_state.board)

      legislative_session = @game.cycles[index].legislative_session

      Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(legislative_session,
                                                                         @game_state.board))

      legislative_session.apply_tactics_preactions(@game_state)

      legislative_session.apply_tactics_actions(@game_state, nil, nil, nil)

      legislative_session.apply_tactics_consequences(@game_state)

      @game_state.apply_legislative_session(legislative_session, true)
      Logger.header(LegislativeSessionRenderer.get.render legislative_session,
                                                          @game_state.board)
      
      Logger.header(BoardRenderer.get.render_sunsetting_bills(@game_state.board,
                                                              @game_state.cur_cycle + 1))
      @game_state.end_cycle(@game.cycles[index], true)
    end
    # error checking
    raise "caught up snapshot disagrees with game state" if
      !@game.final_game_state.equals?(@game_state)
  end
  
  def run(num_cycles)
    catch_up
    
    Logger.subheader "The game is beginning"

    # show the initial hands
    [:A, :B].each do |party|
      Logger.header("Party '#{party}'s hand")
      Logger.header(HandRenderer.get.render @game_state.send("hand_#{party}"))
    end
    
    dice_roller = DiceRoller.new
    num_cycles.times do |index|
      Logger.subheader "Cycle #{@num_catchup_cycles + index + 1} / #{@num_catchup_cycles + num_cycles}"

      Logger.header "Election phase"
      Logger.header(BoardRenderer.get.render @game_state.board)

      election = Election.run_election(@game_state,
                                       @boss_A, @boss_B,
                                       dice_roller)

      Logger.header(ElectionRenderer.get.render election, @game_state.board)      

      Logger.header "Legislative phase"
      Logger.header(BoardRenderer.get.render @game_state.board)

      legislative_session = LegislativeSession.run_session(@game_state,
                                                           @boss_A, @boss_B,
                                                           dice_roller)

      Logger.header(LegislativeSessionRenderer.get.render legislative_session,
                                                          @game_state.board)

      cycle = Cycle.new(election, legislative_session, nil)  # gs fills in SOTU
      Logger.header(BoardRenderer.get.render_sunsetting_bills(@game_state.board,
                                                              @game_state.cur_cycle + 1))
      @game_state.end_cycle(cycle, false)
      @game.cycles.push cycle
    end
    # display the board once more for good measure
    Logger.header(BoardRenderer.get.render @game_state.board)
    Logger.subheader "Game over"
    
    @game.final_game_state = @game_state
    @game
  end

  private

  def make_boss(party, type)
    if type == "HUMAN"
      HumanBoss.new(party, @game_state.send("hand_#{party}"))
    elsif type == "AI"
      RandomBoss.new(party, @game_state.send("hand_#{party}"))
    else
      raise "Unexpected boss type: #{type}"
    end
  end

end
