require_relative 'base_object'
require_relative 'config'
require_relative 'dice_allocation'
require_relative 'dice_outcome'

class LegislativeSession < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "bills_A",       type: Bill,        is_array: true },
    { name: "bills_B",       type: Bill,        is_array: true },
    { name: "allocation_A",  type: DiceAllocation              },
    { name: "allocation_B",  type: DiceAllocation              },
    { name: "outcomes_A",    type: DiceOutcome, is_array: true },
    { name: "outcomes_B",    type: DiceOutcome, is_array: true },
    { name: "bills_dealt_A", type: Bill,        is_array: true },
    { name: "bills_dealt_B", type: Bill,        is_array: true },
  ]

  def LegislativeSession.run_session(game_snapshot, boss_A, boss_B, dice_roller)
    Logger.header("Boss 'A' choosing bills").indent
    bills_A = boss_A.get_bills
    Logger.unindent
    Logger.header("Boss 'A' choosing dice allocation").indent
    allocation_A = boss_A.get_allocation(game_snapshot.board.num_legislative_dice('A'),
                                         bills_A)
    Logger.unindent
    Logger.header("Boss 'B' choosing bills").indent
    bills_B = boss_B.get_bills
    Logger.unindent
    Logger.header("Boss 'B' choosing dice allocation").indent
    allocation_B = boss_B.get_allocation(game_snapshot.board.num_legislative_dice('B'),
                                         bills_B)
    Logger.unindent
    Logger.header(LegislativeSessionRenderer.get.render_bills_on_floor bills_A, bills_B)

    #
    # TODO: tactics
    #
    
    legislative_session = LegislativeSession.new(bills_A,
                                                 bills_B,
                                                 allocation_A,
                                                 allocation_B,
                                                 dice_roller.get_outcomes(allocation_A),
                                                 dice_roller.get_outcomes(allocation_B),
                                                 [], # fill this in below
                                                 []) # fill this in below

    game_snapshot.apply_legislative_session(legislative_session, false)
  end

  def passes?(index, party)
    bill = send("bills_#{party}")[index]
    send("outcomes_#{party}")[index].sum >= bill.vps ? bill : nil
  end

  def vps(index, party, board)
    bill = send("bills_#{party}")[index]
    if passes?(index, party)
      bill.vps + (bill.sector == board.state_of_the_union.priorities[0] ? 1 : 0)
    else
      0
    end
  end
end
