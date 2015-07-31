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

    legislative_session.remove_bills_from_hands(game_snapshot)
    legislative_session.sign_winners_into_law(game_snapshot)

    legislative_session.bills_dealt_A.concat(game_snapshot.deal_bills 'A')
    legislative_session.bills_dealt_B.concat(game_snapshot.deal_bills 'B')
    legislative_session.deal_bills(game_snapshot)

    legislative_session.put_losers_in_deck(game_snapshot)

    legislative_session
  end

  def remove_bills_from_hands(game_snapshot)
    remove_bills_from_hand game_snapshot, 'A'
    remove_bills_from_hand game_snapshot, 'B'
  end
  
  def remove_bills_from_hand(game_snapshot, party)
    send("bills_#{party}").each do |bill|
      game_snapshot.send("hand_#{party}").bills.delete_if { |hand_bill| hand_bill.equals? bill }
    end
  end

  def sign_winners_into_law(game_snapshot)
    board = game_snapshot.board
    ['A', 'B'].each do |party|
      Config.get.bills_num_on_floor.times do |index|
        bill = passes?(index, party)
        if bill
          board.send("passed_bills_#{party}").push bill
          board.increment_vps(party, vps(index, party, board))
        end
      end
    end
  end

  def put_losers_in_deck(game_snapshot)
    ['A', 'B'].each do |party|
      Config.get.bills_num_on_floor.times do |index|
        if !passes?(index, party)
          game_snapshot.bill_deck.push send("bills_#{party}")[index]
        end
      end
    end
  end

  def deal_bills(game_snapshot, remove_from_deck = false)
    game_snapshot.hand_A.bills.concat(bills_dealt_A)
    game_snapshot.hand_B.bills.concat(bills_dealt_B)

    if remove_from_deck
      ['A', 'B'].each do |party|
        send("bills_dealt_#{party}").each do |bill|
          game_snapshot.bill_deck.delete_if { |deck_bill| deck_bill.equals?(bill) }
        end
      end
    end
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
