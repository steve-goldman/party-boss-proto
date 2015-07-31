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
    # create the election
    Logger.header("Boss 'A' choosing candidates").indent
    candidates_A = boss_A.get_candidates(game_snapshot)
    Logger.unindent
    Logger.header("Boss 'B' choosing candidates").indent
    candidates_B = boss_B.get_candidates(game_snapshot)
    Logger.unindent
    Election.log_matchups candidates_A, candidates_B
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
                            [], # fill this in below
                            []) # fill this in below

    election.remove_candidates_from_hands(game_snapshot)
    election.put_winners_in_office(game_snapshot)

    election.politicians_dealt_A.concat(game_snapshot.deal_politicians 'A')
    election.politicians_dealt_B.concat(game_snapshot.deal_politicians 'B')
    election.deal_politicians(game_snapshot)

    election.put_losers_in_deck(game_snapshot)

    election
  end

  def Election.log_matchups(candidates_A, candidates_B)
    Logger.subheader("Election matchups").indent
    Logger.log Politician.matchup_descriptions(candidates_A, candidates_B).join("\n")
    Logger.unindent
  end

  def remove_candidates_from_hands(game_snapshot)
    remove_candidates_from_hand game_snapshot, 'A'
    remove_candidates_from_hand game_snapshot, 'B'
  end
  
  def remove_candidates_from_hand(game_snapshot, party)
    send("candidates_#{party}").each do |candidate|
      game_snapshot.send("hand_#{party}").politicians.delete_if { |politician| politician.equals? candidate }
    end
  end
  
  def put_winners_in_office(game_snapshot)
    Config.get.seats_num.times do |index|
      result = get_result index, game_snapshot.board
      game_snapshot.board.office_holders[index] = OfficeHolder.new result[:winning_party], result[:winner]
    end
  end

  def deal_politicians(game_snapshot, remove_from_deck = false)
    game_snapshot.hand_A.politicians.concat(politicians_dealt_A)
    game_snapshot.hand_B.politicians.concat(politicians_dealt_B)

    if remove_from_deck
      ['A', 'B'].each do |party|
        send("politicians_dealt_#{party}").each do |politician|
          game_snapshot.politician_deck.delete_if { |deck_politician| deck_politician.equals?(politician) }
        end
      end
    end
  end

  def put_losers_in_deck(game_snapshot)
    Config.get.seats_num.times do |index|
      result = get_result index, game_snapshot.board
      game_snapshot.politician_deck.push result[:loser]
    end
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
