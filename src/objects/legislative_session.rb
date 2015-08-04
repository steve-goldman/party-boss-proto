require_relative 'base_object'
require_relative 'config'
require_relative 'dice_allocation'
require_relative 'dice_outcome'
require_relative 'tactics/played_tactic'

class LegislativeSession < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "bills_A",        type: Bill,         is_array: true },
    { name: "bills_B",        type: Bill,         is_array: true },
    { name: "num_dice_A",     type: Integer,                     },
    { name: "num_dice_B",     type: Integer,                     },
    { name: "allocation_A",   type: DiceAllocation               },
    { name: "allocation_B",   type: DiceAllocation               },
    { name: "played_tactics", type: PlayedTactic, is_array: true },
    { name: "outcomes_A",     type: DiceOutcome,  is_array: true },
    { name: "outcomes_B",     type: DiceOutcome,  is_array: true },
    { name: "bills_dealt_A",  type: Bill,         is_array: true },
    { name: "bills_dealt_B",  type: Bill,         is_array: true },
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
    @current_bills_A = bills_A.clone
    @current_bills_B = bills_B.clone
  end
  
  def LegislativeSession.run_session(game_state, boss_A, boss_B, dice_roller)
    num_dice_A = game_state.board.num_leadership_dice('A')
    num_dice_B = game_state.board.num_leadership_dice('B')

    Logger.header("Boss 'A' choosing bills").indent
    bills_A = boss_A.get_bills
    Logger.unindent
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = boss_A.get_allocation(num_dice_A, bills_A)
    Logger.unindent
    Logger.header("Boss 'B' choosing bills").indent
    bills_B = boss_B.get_bills
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = boss_B.get_allocation(num_dice_B, bills_B)
    Logger.unindent

    legislative_session = LegislativeSession.new(bills_A, bills_B,
                                                 num_dice_A, num_dice_B,
                                                 allocation_A, allocation_B,
                                                 [], [], [], [], [])

    legislative_session.get_tactics(game_state, boss_A, boss_B)
    
    Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(legislative_session,
                                                                       game_state.board))

    legislative_session.apply_tactics_actions(game_state, boss_A, boss_B, dice_roller)

    legislative_session.outcomes_A.concat(dice_roller.get_outcomes(legislative_session.get_allocation('A'),
                                                                   legislative_session.all_dice_outcomes('A')))
    legislative_session.outcomes_B.concat(dice_roller.get_outcomes(legislative_session.get_allocation('B'),
                                                                   legislative_session.all_dice_outcomes('B')))
    
    game_state.apply_legislative_session(legislative_session, false)
  end

  def passes?(index, party)
    send("outcomes_#{party}")[index].sum >= bill_cost(index, party) ?
      get_bill_on_floor(index, party) : nil
  end

  def vps(index, party, board)
    bill = passes?(index, party)
    bill ? bill_vps(index, party, board) : 0
  end

  def bill_vps(index, party, board)
    bill = get_bill_on_floor(index, party)
    (bill.sector == board.state_of_the_union.priorities[0] ? 1 : 0) +
      (party == 'A' ? @bill_A_vps[index] : @bill_B_vps[index])
  end

  def bill_cost(index, party)
    party == 'A' ? @bill_A_cost[index] : @bill_B_cost[index]
  end

  def set_all_dice_count_as(index, party, count)
    party == 'A' ?
      @bill_A_all_dice_outcomes[index] = count :
      @bill_B_all_dice_outcomes[index] = count
    outcomes = party == 'A' ? @bill_A_all_dice_outcomes : @bill_B_all_dice_outcomes
  end

  def all_dice_outcomes(party)
    party == 'A' ? @bill_A_all_dice_outcomes : @bill_B_all_dice_outcomes
  end

  def get_allocation(party)
    party == 'A' ? @allocation_A : @allocation_B
  end

  def get_bill_allocation(index, party)
    party == 'A' ?
      @allocation_A.counts[index] :
      @allocation_B.counts[index]
  end

  def set_bill_allocation(index, party, count)
    party == 'A' ?
      @allocation_A.counts[index] = count :
      @allocation_B.counts[index] = count
  end

  def change_bill_allocation(index, party, delta)
    party == 'A' ?
      @allocation_A.counts[index] += [num_dice_A - @allocation_A.sum, delta].min :
      @allocation_B.counts[index] += [num_dice_B - @allocation_B.sum, delta].min
  end

  def give_dice_to_opponent(index, party, count)
    if party == 'A'
      delta = [count, @allocation_A.counts[index]].min
      @allocation_B.counts[index] += delta
      @allocation_A.counts[index] -= delta
    else
      delta = [count, @allocation_B.counts[index]].min
      @allocation_A.counts[index] += delta
      @allocation_B.counts[index] -= delta
    end
  end

  def apply_tactics_actions(game_state, boss_A, boss_B, dice_roller)
    played_tactics.each do |played_tactic|
      if played_tactic.immediate?
        played_tactic.apply_preactions(game_state, boss_A, boss_B) if boss_A.nil?
      else
        Logger.subheader("Applying #{played_tactic.tactic} played by '#{played_tactic.party_played_by}' on '#{played_tactic.party_played_on}'s bill").indent
        played_tactic.apply_actions(game_state.board, self,
                                    boss_A, boss_B, dice_roller)
        Logger.unindent
      end
    end
  end

  def get_bill_on_floor(index, party)
    party == 'A' ?
      @current_bills_A[index] :
      @current_bills_B[index]
  end

  def get_bills_on_floor(party)
    party == 'A' ?
      @current_bills_A :
      @current_bills_B
  end

  def table_bill(index, party, replacement_bill)
    party == 'A' ?
      @current_bills_A[index] = replacement_bill :
      @current_bills_B[index] = replacement_bill
  end

  def get_tactics(game_state, boss_A, boss_B)
    last_last_was_pass = false
    last_was_pass = false
    party = game_state.board.tactics_lead_party
    while !last_was_pass || !last_last_was_pass
      Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(self, game_state.board))
      Logger.header("Boss #{party} choosing a tactic").indent
      arr = (party == 'A' ? boss_A : boss_B).get_tactic(self)
      tactic = arr[0]
      if tactic == Tactic::Pass
        last_last_was_pass = true if last_was_pass
        last_was_pass = true
      else
        index = arr[1]; party_played_on = arr[2]
        played_tactic = PlayedTactic.new(party, party_played_on, index, tactic,
                                         nil, nil, nil, nil)
        if !played_tactic.can_play(game_state.board, self)
          Logger.error "This tactic cannot be played like this"
          # make them choose again
          party = (party == 'A' ? 'B' : 'A')
        else
          last_was_pass = false
          # remove from the hand
          game_state.send("hand_#{party}").tactics.delete_if do |hand_tactic|
            hand_tactic.equals?(tactic)
          end
          # handle filibusters, tabling motions, and clotures
          played_tactic.apply_preactions(game_state, boss_A, boss_B)
          # make it official
          played_tactics.push(played_tactic)
        end
      end
      party = (party == 'A' ? 'B' : 'A')
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

end
