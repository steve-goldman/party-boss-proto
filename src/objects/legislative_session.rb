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
    @clotured_A = bills_A.map { false }
    @clotured_B = bills_B.map { false }
    @auto_pass_A = bills_A.map { false }
    @auto_pass_B = bills_B.map { false }
  end
  
  def LegislativeSession.run_session(game_state, boss_A, boss_B, dice_roller)
    Logger.header("Boss 'A' has #{game_state.board.num_leadership_dice(:A)} leadership dice")
    Logger.header("Boss 'A' choosing bills").indent
    bills_A = boss_A.get_bills
    Logger.unindent
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = boss_A.get_allocation(game_state.board.num_leadership_dice(:A), bills_A)
    Logger.unindent
    Logger.header("Boss 'B' has #{game_state.board.num_leadership_dice(:B)} leadership dice")
    Logger.header("Boss 'B' choosing bills").indent
    bills_B = boss_B.get_bills
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = boss_B.get_allocation(game_state.board.num_leadership_dice(:B), bills_B)
    Logger.unindent

    legislative_session = LegislativeSession.new(bills_A, bills_B,
                                                 allocation_A, allocation_B,
                                                 [], [], [], [], [])

    legislative_session.get_tactics(game_state, boss_A, boss_B)
    
    Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(legislative_session,
                                                                       game_state.board))

    legislative_session.apply_tactics_actions(game_state, boss_A, boss_B, dice_roller)

    legislative_session.outcomes_A.concat(dice_roller.get_outcomes(legislative_session.get_allocation(:A),
                                                                   legislative_session.all_dice_outcomes(:A)))
    legislative_session.outcomes_B.concat(dice_roller.get_outcomes(legislative_session.get_allocation(:B),
                                                                   legislative_session.all_dice_outcomes(:B)))
    
    legislative_session.apply_tactics_consequences(game_state)

    game_state.apply_legislative_session(legislative_session, false)
  end

  def num_bills_passed(party)
    Config.get.bills_num_sessions.times.select { |index|
      passes?(index, party)
    }.count
  end

  def passes?(index, party)
    auto_passes?(index, party) ||
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
      (party == :A ? @bill_A_vps[index] : @bill_B_vps[index])
  end

  def incr_bill_vps(index, party, board, delta)
    party == :A ?
      @bill_A_vps[index] = [@bill_A_vps[index] + delta, 0].max :
      @bill_B_vps[index] = [@bill_B_vps[index] + delta, 0].max
    bill_vps(index, party, board)
  end

  def bill_cost(index, party)
    party == :A ? @bill_A_cost[index] : @bill_B_cost[index]
  end

  def incr_bill_cost(index, party, delta)
    party == :A ?
      @bill_A_cost[index] = [@bill_A_cost[index] + delta, 0].max :
      @bill_B_cost[index] = [@bill_B_cost[index] + delta, 0].max
  end

  def auto_pass_bill(index, party)
    party == :A ?
      @auto_pass_A[index] = true :
      @auto_pass_B[index] = true
  end

  def set_all_dice_count_as(index, party, count)
    party == :A ?
      @bill_A_all_dice_outcomes[index] = count :
      @bill_B_all_dice_outcomes[index] = count
  end

  def all_dice_outcomes(party)
    party == :A ? @bill_A_all_dice_outcomes : @bill_B_all_dice_outcomes
  end

  def get_allocation(party)
    party == :A ? @allocation_A : @allocation_B
  end

  def get_bill_allocation(index, party)
    party == :A ?
      @allocation_A.counts[index] :
      @allocation_B.counts[index]
  end

  def set_bill_allocation(index, party, count)
    party == :A ?
      @allocation_A.counts[index] = count :
      @allocation_B.counts[index] = count
  end

  def change_bill_allocation(index, party, delta)
    party == :A ?
      @allocation_A.counts[index] += [Config.get.leadership_dice_max - @allocation_A.sum, delta].min :
      @allocation_B.counts[index] += [Config.get.leadership_dice_max - @allocation_B.sum, delta].min
  end

  def give_dice_to_opponent(index, party, count)
    if party == :A
      delta = [count, @allocation_A.counts[index]].min
      @allocation_B.counts[index] += delta
      @allocation_A.counts[index] -= delta
    else
      delta = [count, @allocation_B.counts[index]].min
      @allocation_A.counts[index] += delta
      @allocation_B.counts[index] -= delta
    end
  end

  def apply_tactics_preactions(game_state)
    played_tactics.each do |played_tactic|
      log_if_output("Applying #{played_tactic} [1]",
                    played_tactic.apply_preactions(self, game_state, nil, nil))
    end
  end

  def apply_tactics_actions(game_state, boss_A, boss_B, dice_roller)
    played_tactics.each do |played_tactic|
      if !played_tactic.immediate?
        # confirm that the preconditions still hold in case a tactic
        # (i.e. tabling motion) changed things
        if played_tactic.can_play(game_state.board, self)
          log_if_output("Applying #{played_tactic} [2]",
                        played_tactic.apply_actions(self, game_state,
                                                    boss_A, boss_B, dice_roller))
        end
      end
    end
  end

  def apply_tactics_consequences(game_state)
    played_tactics.each do |played_tactic|
      if !played_tactic.immediate?
        # confirm that the preconditions still hold in case a tactic
        # (i.e. tabling motion) changed things
        if played_tactic.can_play(game_state.board, self)
          log_if_output("Applying #{played_tactic} [3]",
                        played_tactic.apply_consequences(game_state.board, self))
        end
      end
    end
  end

  def get_bill_on_floor(index, party)
    party == :A ?
      @current_bills_A[index] :
      @current_bills_B[index]
  end

  def get_bills_on_floor(party)
    party == :A ?
      @current_bills_A :
      @current_bills_B
  end

  def table_bill(index, party, replacement_bill)
    if party == :A
      @bill_A_vps[index]      += (replacement_bill.vps - @current_bills_A[index].vps)
      @bill_A_cost[index]     += (replacement_bill.vps - @current_bills_A[index].vps)
      @current_bills_A[index]  = replacement_bill
    else
      @bill_B_vps[index]      += (replacement_bill.vps - @current_bills_B[index].vps)
      @bill_B_cost[index]     += (replacement_bill.vps - @current_bills_B[index].vps)
      @current_bills_B[index]  = replacement_bill
    end
  end

  def cloture_bill(index, party)
    party == :A ? @clotured_A[index] = true : @clotured_B[index] = true
  end

  def clotured?(index, party)
    party == :A ? @clotured_A[index] : @clotured_B[index]
  end

  def get_tactics(game_state, boss_A, boss_B)
    last_last_was_pass = false
    last_was_pass = false
    party = game_state.board.tactics_lead_party.to_sym
    while !last_was_pass || !last_last_was_pass
      Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor(self, game_state.board))
      Logger.header("Boss #{party} choosing a tactic").indent
      arr = (party == :A ? boss_A : boss_B).get_tactic(self)
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
          party = (party == :A ? :B : :A)
        else
          last_was_pass = false
          # remove from the hand
          game_state.send("hand_#{party}").tactics.delete_if do |hand_tactic|
            hand_tactic.equals?(tactic)
          end
          # handle filibusters, tabling motions, and clotures
          log_if_output("Applying #{played_tactic} [1]",
                        played_tactic.apply_preactions(self, game_state, boss_A, boss_B))
          # make it official
          played_tactics.push(played_tactic)
        end
      end
      party = (party == :A ? :B : :A)
      Logger.unindent
    end
  end

  private

  def init_bill_vps(bills)
    bills.map { |bill| bill.vps }
  end

  def auto_passes?(index, party)
    party == :A ? @auto_pass_A[index] : @auto_pass_B[index]
  end

  def log_if_output(header, output)
    if !output.nil? && !output.empty?
      Logger.subheader(header).indent
      Logger.log(output).unindent
    end
  end

end
