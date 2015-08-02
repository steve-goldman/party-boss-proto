require_relative 'base_object'
require_relative 'config'
require_relative 'dice_allocation'
require_relative 'dice_outcome'
require_relative 'tactics/played_tactic'

class LegislativeSession < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "bills_A",       type: Bill,         is_array: true },
    { name: "bills_B",       type: Bill,         is_array: true },
    { name: "allocation_A",  type: DiceAllocation              },
    { name: "allocation_B",  type: DiceAllocation              },
    { name: "tactics",       type: PlayedTactic, is_array: true },
    { name: "outcomes_A",    type: DiceOutcome,  is_array: true },
    { name: "outcomes_B",    type: DiceOutcome,  is_array: true },
    { name: "bills_dealt_A", type: Bill,         is_array: true },
    { name: "bills_dealt_B", type: Bill,         is_array: true },
  ]

  def after_init
    @bill_A_vps =  init_bill_vps(bills_A)
    @bill_B_vps =  init_bill_vps(bills_B)
    @bill_A_cost = init_bill_vps(bills_A)
    @bill_B_cost = init_bill_vps(bills_B)
    @bill_A_all_dice_outcomes = bills_A.map { -1 }
    @bill_B_all_dice_outcomes = bills_B.map { -1 }
    @allocation_A = allocation_A.clone
    @allocation_B = allocation_B.clone
  end
  
  def LegislativeSession.run_session(game_snapshot, boss_A, boss_B, dice_roller)
    Logger.header("Boss 'A' choosing bills").indent
    bills_A = boss_A.get_bills
    Logger.unindent
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = boss_A.get_allocation(game_snapshot.board.num_leadership_dice('A'),
                                         bills_A)
    Logger.unindent
    Logger.header("Boss 'B' choosing bills").indent
    bills_B = boss_B.get_bills
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = boss_B.get_allocation(game_snapshot.board.num_leadership_dice('B'),
                                         bills_B)
    Logger.unindent
    legislative_session = LegislativeSession.new(bills_A,
                                                 bills_B,
                                                 allocation_A,
                                                 allocation_B,
                                                 [], [], [], [], [])

    LegislativeSession.get_tactics(legislative_session, game_snapshot, boss_A, boss_B)
    
    Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(legislative_session,
                                                                       game_snapshot.board))

    LegislativeSession.apply_tactics_actions(legislative_session, game_snapshot, boss_A, boss_B, dice_roller)

    legislative_session.outcomes_A.concat(dice_roller.get_outcomes(legislative_session.get_allocation('A'),
                                                                   legislative_session.all_dice_outcomes('A')))
    legislative_session.outcomes_B.concat(dice_roller.get_outcomes(legislative_session.get_allocation('B'),
                                                                   legislative_session.all_dice_outcomes('B')))
    
    game_snapshot.apply_legislative_session(legislative_session, false)
  end

  def passes?(index, party)
    bill = send("bills_#{party}")[index]
    send("outcomes_#{party}")[index].sum >= bill_cost(index, party) ? bill : nil
  end

  def vps(index, party, board)
    bill = passes?(index, party)
    bill ? bill_vps(index, party, board) : 0
  end

  def bill_vps(index, party, board)
    bill = send("bills_#{party}")[index]
    (bill.sector == board.state_of_the_union.priorities[0] ? 1 : 0) +
      (party == 'A' ? @bill_A_vps[index] : @bill_B_vps[index])
  end

  def bill_cost(index, party)
    party == 'A' ? @bill_A_cost[index] : @bill_B_cost[index]
  end

  def get_bill_cost(bill)
    party_index = get_bill_party_index(bill)
    return bill_cost(party_index[0], party_index[1])
  end

  def change_bill_cost(bill, delta)
    party_index = get_bill_party_index(bill)
    return incr_bill_cost(party_index[0], party_index[1], delta)
  end

  def set_all_dice_count_as(bill, count)
    party_index = get_bill_party_index(bill)
    party_index[1] == 'A' ?
      @bill_A_all_dice_outcomes[party_index[0]] = count :
      @bill_B_all_dice_outcomes[party_index[0]] = count
    outcomes = party_index[1] == 'A' ? @bill_A_all_dice_outcomes : @bill_B_all_dice_outcomes
  end

  def all_dice_outcomes(party)
    party == 'A' ? @bill_A_all_dice_outcomes : @bill_B_all_dice_outcomes
  end

  def get_allocation(party)
    party == 'A' ? @allocation_A : @allocation_B
  end

  def get_bill_allocation(bill)
    party_index = get_bill_party_index(bill)
    party_index[1] == 'A' ?
      @allocation_A.counts[party_index[0]] :
      @allocation_B.counts[party_index[0]]
  end

  def set_bill_allocation(bill, count)
    party_index = get_bill_party_index(bill)
    party_index[1] == 'A' ?
      @allocation_A.counts[party_index[0]] = count :
      @allocation_B.counts[party_index[0]] = count
  end

  def LegislativeSession.apply_tactics_actions(legislative_session, game_snapshot,
                                               boss_A, boss_B, dice_roller)
    legislative_session.tactics.each do |played_tactic|
      Logger.subheader("Applying #{played_tactic.tactic} played by '#{played_tactic.party_played_by}' on '#{played_tactic.party_played_on}'s bill").indent
      played_tactic.apply_actions(game_snapshot.board, legislative_session,
                                  boss_A, boss_B, dice_roller)
      Logger.unindent
    end
  end

  private

  def init_bill_vps(bills)
    bills.map { |bill| bill.vps }
  end

  def incr_bill_cost(index, party, delta)
    party == 'A' ?
      @bill_A_cost[index] = [@bill_A_cost[index] + delta, 0].max :
      @bill_B_cost[index] = [@bill_B_cost[index] + delta, 0].max
  end

  def get_bill_party_index(bill)
    ['A', 'B'].each do |party|
      bills = send("bills_#{party}") 
      bills.each_index do |index|
        return [index, party] if bill.equals?(bills[index])
      end
    end
  end

  def LegislativeSession.get_tactics(legislative_session, game_snapshot, boss_A, boss_B)
    last_last_was_pass = false
    last_was_pass = false
    party = 'A'  # TODO
    while !last_was_pass || !last_last_was_pass
      Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(legislative_session,
                                                                         game_snapshot.board))
      Logger.header("Boss #{party} choosing a tactic").indent
      arr = (party == 'A' ? boss_A : boss_B).get_tactic(legislative_session)
      tactic = arr[0]
      if tactic == Tactic::Pass
        last_last_was_pass = true if last_was_pass
        last_was_pass = true
      else
        drawn_tactics = LegislativeSession.handle_filibuster(game_snapshot, tactic, party)
        index = arr[1]; party_played_on = arr[2]
        played_tactic = PlayedTactic.new(party, party_played_on,
                                         index ? legislative_session.bills_A[index] : nil,
                                         index ? legislative_session.bills_B[index] : nil,
                                         tactic, drawn_tactics, nil)
        if !played_tactic.can_play(game_snapshot.board)
          Logger.error "This tactic cannot be played like this"
          # make them choose again
          party = (party == 'A' ? 'B' : 'A')
        else
          last_was_pass = false
          game_snapshot.send("hand_#{party}").tactics.delete_if do |hand_tactic|
            hand_tactic.equals?(tactic)
          end
          legislative_session.tactics.push(played_tactic)
        end
      end
      party = (party == 'A' ? 'B' : 'A')
      Logger.unindent
    end
  end

  def LegislativeSession.handle_filibuster(game_snapshot, tactic, party)
    if tactic.is_filibuster
      drawn_tactics = game_snapshot.deal_tactics(party, 1)
      if !drawn_tactics.empty?
        game_snapshot.send("hand_#{party}").tactics.concat(drawn_tactics)
        Logger.subheader("You drew: #{drawn_tactics[0]}")
      else
        Logger.subheader("The tactics deck is empty")
      end
    else
      drawn_tactics = nil
    end
    drawn_tactics
  end

end
