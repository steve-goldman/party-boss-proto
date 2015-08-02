require_relative 'base_object'
require_relative 'config'
require_relative 'dice_allocation'
require_relative 'dice_outcome'

class Election < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "candidates_A",        type: Politician,   is_array: true },
    { name: "candidates_B",        type: Politician,   is_array: true },
    { name: "allocation_A",        type: DiceAllocation },
    { name: "allocation_B",        type: DiceAllocation },
    { name: "outcomes_A",          type: DiceOutcome,  is_array: true },
    { name: "outcomes_B",          type: DiceOutcome,  is_array: true },
    { name: "politicians_dealt_A", type: Politician,   is_array: true },
    { name: "politicians_dealt_B", type: Politician,   is_array: true },
    { name: "tactics_dealt_A",     type: Tactic,       is_array: true },
    { name: "tactics_dealt_B",     type: Tactic,       is_array: true },
  ]

  def get_result(index, board)
    @result = @result || []
    if @result[index].nil?
      winner = get_winner(index, board)
      a_wins = (winner == candidates_A[index])
      @result[index] = { winner:        winner,
                         loser:         a_wins ? candidates_B[index] : candidates_A[index],
                         winning_party: a_wins ? 'A' : 'B',
                         losing_party:  a_wins ? 'B' : 'A' }
    end

    @result[index]
  end

  def Election.run_election(game_snapshot, boss_A, boss_B, dice_roller)
    # create the election
    Logger.header("Boss 'A' choosing candidates").indent
    candidates_A = boss_A.get_candidates(game_snapshot)
    Logger.unindent
    Logger.header("Boss 'B' choosing candidates").indent
    candidates_B = boss_B.get_candidates(game_snapshot)
    Logger.unindent
    Logger.header(ElectionRenderer.get.render_matchups candidates_A, candidates_B)
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = boss_A.get_allocation(game_snapshot.board.num_fundraising_dice(candidates_A),
                                         Politician.matchup_descriptions(candidates_A, candidates_B))
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = boss_B.get_allocation(game_snapshot.board.num_fundraising_dice(candidates_B),
                                         Politician.matchup_descriptions(candidates_B, candidates_A))
    Logger.unindent
    election = Election.new(candidates_A,
                            candidates_B,
                            allocation_A,
                            allocation_B,
                            dice_roller.get_outcomes(allocation_A),
                            dice_roller.get_outcomes(allocation_B),
                            [], [], [], [])

    game_snapshot.apply_election(election, false)
  end

  def points(index, board, party)
    strength_points(index, board, party) + outcomes_points(index, party)
  end

  def strength_points(index, board, party)
    send("candidates_#{party}")[index].strength(board.state_of_the_union.priorities[0])
  end

  def outcomes_points(index, party)
    send("outcomes_#{party}")[index].sum
  end

  private
  
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
    elsif candidates_A[index].equals?(board.office_holders[index].politician)
      candidates_A[index]
    else
      candidates_B[index]
    end
  end

end
