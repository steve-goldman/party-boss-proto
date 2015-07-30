require_relative 'base_object'
require_relative 'config'
require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "candidates_A",       type: Politician,   is_array: true },
    { name: "candidates_B",       type: Politician,   is_array: true },
    { name: "allocation_A",       type: DiceAllocation },
    { name: "allocation_B",       type: DiceAllocation },
    { name: "outcomes_A",         type: DiceOutcome,  is_array: true },
    { name: "outcomes_B",         type: DiceOutcome,  is_array: true },
  ]

  def get_result(index, board)
    winner = get_winner index, board

    {
      winner: winner,
      loser: winner == candidates_A[index] ? candidates_B[index] : candidates_A[index],
      winning_party: winner == candidates_A[index] ? 'A' : 'B',
      losing_party: winner == candidates_A[index] ? 'B' : 'A'
    }
  end

  def Election.run_election(game_snapshot, boss_A, boss_B, dice_roller)
    Logger.header game_snapshot.board.description
    Logger.header("Boss 'A' choosing candidates").indent
    candidates_A = boss_A.get_candidates(game_snapshot)
    Logger.unindent
    Logger.header("Boss 'B' choosing candidates").indent
    candidates_B = boss_B.get_candidates(game_snapshot)
    Logger.unindent
    Logger.header("Election matchups").indent
    Config.get.seats_num.times do |index|
      Logger.log "#{candidates_A[index]} versus #{candidates_B[index]}"
    end
    Logger.unindent
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = boss_A.get_allocation(game_snapshot, candidates_A, candidates_B)
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = boss_B.get_allocation(game_snapshot, candidates_B, candidates_A)
    Logger.unindent
    election = Election.new(candidates_A,
                            candidates_B,
                            allocation_A,
                            allocation_B,
                            dice_roller.get_outcomes(allocation_A),
                            dice_roller.get_outcomes(allocation_B))
    Logger.header(election.description game_snapshot.board).indent
    Logger.unindent
    election
  end

  def description(board)
    defeats = " DEFEATS "
    results_array = []
    Config.get.seats_num.times do |index|
      result = get_result index, board
      results_array << sprintf("%-#{Politician::MaxLength}s (party '%s') #{defeats} %-#{Politician::MaxLength}s (party '%s')",
                               result[:winner],
                               result[:winning_party],
                               result[:loser],
                               result[:losing_party])
      results_array << sprintf("%-#{Politician::MaxLength}s %s %-#{Politician::MaxLength}s",
                               breakdown_str(index, board, result[:winning_party]),
                               " " * ("(party 'x') #{defeats}".length),
                               breakdown_str(index, board, result[:losing_party]))
                               
    end

    [
      "Election results",
      ""
    ].concat(results_array).join("\n")
  end

  private
  
  def breakdown_str(index, board, party)
    "#{points(index, board, party)} = #{strength_points(index, board, party)} + #{outcomes(index, party)}"
  end

  def strength_points(index, board, party)
    party == 'A' ?
      candidates_A[index].strength(board.state_of_the_union.priorities[0]) :
      candidates_B[index].strength(board.state_of_the_union.priorities[0])
  end

  def outcomes(index, party)
    (send "outcomes_#{party}")[index]
  end

  def outcomes_points(index, party)
    outcomes(index, party).sum
  end

  def points(index, board, party)
    strength_points(index, board, party) + outcomes_points(index, party)
  end

  def get_winner(index, board)
    if points(index, board, 'A') > points(index, board, 'B')
      candidates_A[index]
    elsif points(index, board, 'A') < points(index, board, 'B')
      candidates_B[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[1]) >
          candidates_B[index].strength(board.state_of_the_union.priorities[1])
      candidates_A[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[1]) <
          candidates_B[index].strength(board.state_of_the_union.priorities[1])
      candidates_B[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[2]) >
          candidates_B[index].strength(board.state_of_the_union.priorities[2])
      candidates_A[index]
    elsif candidates_A[index].strength(board.state_of_the_union.priorities[2]) <
          candidates_B[index].strength(board.state_of_the_union.priorities[2])
      candidates_B[index]
    elsif candidates_A[index] == board.office_holders[index].politician
      candidates_A[index]
    else
      candidates_B[index]
    end
  end

end
