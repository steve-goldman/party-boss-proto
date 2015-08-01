require_relative 'base_object'
require_relative 'config'
require_relative 'board'
require_relative 'hand'

class GameSnapshot < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "board",  type: Board },
    { name: "hand_A", type: Hand  },
    { name: "hand_B", type: Hand  },
    { name: "politician_deck",         type: Politician,      is_array: true, unordered: true },
    { name: "bill_deck",               type: Bill,            is_array: true, unordered: true },
    { name: "state_of_the_union_deck", type: StateOfTheUnion, is_array: true, unordered: true },
    { name: "tactic_deck",             type: Tactic,          is_array: true, unordered: true },
  ]

  # utility method for creating a new game
  def GameSnapshot.new_game
    # create the decks of politicians
    politician_deck = Politician.from_array_file('src/data/politicians.json').shuffle
    bill_deck = Bill.from_array_file('src/data/bills.json').shuffle
    state_of_the_union_deck = StateOfTheUnion.from_array_file('src/data/state_of_the_unions.json').shuffle
    tactic_deck = Tactic.from_array_file('src/data/tactics.json')
    # set the initial office holders from the politician_deck
    office_holders = []
    Config.get.seats_num.times do
      office_holders.push OfficeHolder.new(office_holders.count % 2 == 0 ? 'A' : 'B', politician_deck.pop)
    end
    # create the board
    board = Board.new(state_of_the_union_deck.pop, office_holders, [], [], 0, 0)
    # create the snapshot
    game_snapshot = GameSnapshot.new(board,
                                     Hand.new([], [], []),
                                     Hand.new([], [], []),
                                     politician_deck,
                                     bill_deck,
                                     state_of_the_union_deck,
                                     tactic_deck)
    # deal the cards
    ['A', 'B'].each do |party|
      game_snapshot.send("hand_#{party}").politicians.concat(game_snapshot.deal_politicians party)
      game_snapshot.send("hand_#{party}").bills.concat(game_snapshot.deal_bills party)
      game_snapshot.send("hand_#{party}").tactics.concat(game_snapshot.deal_tactics party, Config.get.tactics_num_initial)
    end
    game_snapshot
  end

  def apply_election(election, is_replay)
    # remove candidates from hands
    ['A', 'B'].each do |party|
      election.send("candidates_#{party}").each do |candidate|
        send("hand_#{party}").politicians.delete_if do |politician|
          politician.equals?(candidate)
        end
      end
    end

    # put the winners in office
    Config.get.seats_num.times do |index|
      result = election.get_result(index, board)
      board.office_holders[index] =
        OfficeHolder.new(result[:winning_party], result[:winner])
    end

    # handle with the dealt politician cards
    ['A', 'B'].each do |party|
      if !is_replay
        # deal the cards
        election.send("politicians_dealt_#{party}").concat(deal_politicians party)
      else
        # this is a replay, so take the dealt cards out of the deck
        election.send("politicians_dealt_#{party}").each do |politician|
          politician_deck.delete_if do |deck_politician|
            deck_politician.equals?(politician)
          end
        end
      end
      # put the cards in the hand
      send("hand_#{party}").politicians.concat(
        election.send("politicians_dealt_#{party}"))
    end

    # put the losers back in the deck
    Config.get.seats_num.times do |index|
      result = election.get_result(index, board)
      politician_deck.push(result[:loser])
    end

    election
  end

  def apply_legislative_session(legislative_session, is_replay)
    ['A', 'B'].each do |party|
      # remove bills from hands
      legislative_session.send("bills_#{party}").each do |bill|
        send("hand_#{party}").bills.delete_if do |hand_bill|
          hand_bill.equals?(bill)
        end
      end

      # sign winners into law
      Config.get.bills_num_on_floor.times do |index|
        bill = legislative_session.passes?(index, party)
        if bill
          board.send("passed_bills_#{party}").push(bill)
          board.increment_vps(party, legislative_session.vps(index, party, board))
        end
      end
    end

    # handle with the dealt bill cards
    ['A', 'B'].each do |party|
      if !is_replay
        # deal the cards
        legislative_session.send("bills_dealt_#{party}").concat(deal_bills party)
      else
        # this is a replay, so take the dealt cards out of the deck
        legislative_session.send("bills_dealt_#{party}").each do |bill|
          bill_deck.delete_if do |deck_bill|
            deck_bill.equals?(bill)
          end
        end
      end
      # put the cards in the hand
      send("hand_#{party}").bills.concat(
        legislative_session.send("bills_dealt_#{party}"))      
    end

    # put the losers back in the deck
    ['A', 'B'].each do |party|
      Config.get.bills_num_on_floor.times do |index|
        if !legislative_session.passes?(index, party)
          bill_deck.push(legislative_session.send("bills_#{party}")[index])
        end
      end
    end

    legislative_session
  end

  def deal_politicians(party)
    politician_deck.shuffle!
    num_to_deal = Config.get.politicians_num_in_party - send("hand_#{party}").politicians.count - board.num_encumbents(party)
    [num_to_deal, politician_deck.count].min.times.map do
      politician_deck.pop
    end
  end

  def deal_bills(party)
    bill_deck.shuffle!
    num_to_deal = Config.get.bills_num_in_committee - send("hand_#{party}").bills.count
    [num_to_deal, bill_deck.count].min.times.map do
      bill_deck.pop
    end
  end

  def deal_tactics(party, num_to_deal)
    tactic_deck.shuffle!
    [num_to_deal, tactic_deck.count].min.times.map do
      tactic_deck.pop
    end
  end

  def end_cycle(cycle, is_replay)
    old_state_of_the_union = board.state_of_the_union
    if !is_replay
      cycle.next_state_of_the_union = state_of_the_union_deck.shuffle!.pop
    else
      state_of_the_union_deck.delete_if do |deck_state_of_the_union|
        deck_state_of_the_union.equals?(cycle.next_state_of_the_union)
      end
    end
    board.state_of_the_union = cycle.next_state_of_the_union
    state_of_the_union_deck.push old_state_of_the_union
  end

end
