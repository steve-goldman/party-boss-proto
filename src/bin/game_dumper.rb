require_relative 'game_engine'

class GameDumper < GameEngine

  def initialize(options)
    super(options)
    @election_fields = options[:election_fields]
    @legislative_session_fields = options[:legislative_session_fields]
    @cycle_fields = options[:cycle_fields]
    dump_headers
  end

  def before_apply_election(game_state, election)
    @election_items = @election_fields.map do |field|
      if field.end_with?("_A") || field.end_with?("_B")
        send(field[0..-3], field[-1].to_sym, game_state, election)
      else
        send(field, game_state, election)
      end
    end
  end

  def before_apply_legislative_session(game_state, legislative_session)
    @legislative_session_items = @legislative_session_fields.map do |field|
      if field.end_with?("_A") || field.end_with?("_B")
        send(field[0..-3], field[-1].to_sym, game_state, legislative_session)
      else
        send(field, game_state, legislative_session)
      end
    end
  end

  def before_end_cycle(game_state, cycle)
    cycle_items = @cycle_fields.map do |field|
      send(field, game_state, cycle)
    end
    dump_arrays(@election_items, @legislative_session_items, cycle_items)
  end

  private

  def dump_headers
    dump_arrays(@election_fields, @legislative_session_fields, @cycle_fields)    
  end
  
  def dump_arrays(arr1, arr2, arr3)
    puts (arr1 + arr2 + arr3).join(",")
  end

  #
  # election fields
  #
  
  def encumbent_churn(game_state, election)
    Config.get.seats_num.times.select { |index|
      game_state.board.office_holders[index].party.to_sym !=
        election.get_result(index, game_state.board)[:winning_party]
    }.count
  end

  def num_seats(party, game_state, election)
    game_state.board.num_encumbents(party)
  end

  def delta_seats(party, game_state, election)
    election.num_winners(party, game_state.board) -
      num_seats(party, game_state, election)
  end

  def funds_avail(party, game_state, election)
    game_state.board.num_fundraising_dice(party, election.send("candidates_#{party}"))
  end

  def funds_spent(party, game_state, election)
    election.send("allocation_#{party}").sum
  end

  #
  # legislative session fields
  #

  def leadership_avail(party, game_state, legislative_session)
    game_state.board.num_leadership_dice(party)
  end

  def bills_passed(party, game_state, legislative_session)
    legislative_session.num_bills_passed(party)
  end

  #
  # cycle fields
  #

  def sotu(game_state, cycle)
    game_state.board.state_of_the_union.to_short_s
  end

end

options = {
  input_file: nil,
  boss_A: "HUMAN",
  boss_B: "HUMAN",
  election_fields: [],
  legislative_session_fields: [],
  cycle_fields: [],
}

opt_parser = OptionParser.new do |opts|
  
  opts.on("-i", "--input-file FILE",
          "JSON file to load game state from") do |file|
    options[:input_file] = file
  end

  opts.on("-e", "--election-field FIELD",
          "field name") do |election_field|
    options[:election_fields].push(election_field)
  end
    
  opts.on("-l", "--legislative-session-field FIELD",
          "field name") do |legislative_session_field|
    options[:legislative_session_fields].push(legislative_session_field)
  end
    
  opts.on("-c", "--cycle-field FIELD",
          "field name") do |cycle_field|
    options[:cycle_fields].push(cycle_field)
  end
    
end

Logger.set_silent

opt_parser.parse!

raise "Must specify input-file" if options[:input_file].nil?

engine = GameDumper.new(options)
engine.catch_up
