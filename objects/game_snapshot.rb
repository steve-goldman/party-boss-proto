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
  ]

  # utility method for creating a new game
  def GameSnapshot.new_game
    # create the decks of politicians
    politician_deck = Politician.from_array_file('data/politicians.json').shuffle
    bill_deck = Bill.from_array_file('data/bills.json').shuffle
    state_of_the_union_deck = StateOfTheUnion.from_array_file('data/state_of_the_unions.json').shuffle
    # set the initial office holders from the politician_deck
    office_holders = []
    Config.get.seats_num.times do
      office_holders << OfficeHolder.new(office_holders.count % 2 == 0 ? 'A' : 'B', politician_deck.pop)
    end
    # create the board
    board = Board.new(state_of_the_union_deck.pop, office_holders, [], [], 0, 0)
    # create the snapshot
    game_snapshot = GameSnapshot.new(board,
                                     Hand.new([], []),
                                     Hand.new([], []),
                                     politician_deck,
                                     bill_deck,
                                     state_of_the_union_deck)
    # deal the cards
    game_snapshot.hand_A.politicians.concat(game_snapshot.deal_politicians 'A')
    game_snapshot.hand_B.politicians.concat(game_snapshot.deal_politicians 'B')
    game_snapshot.hand_A.bills.concat(game_snapshot.deal_bills 'A')
    game_snapshot.hand_B.bills.concat(game_snapshot.deal_bills 'B')
    game_snapshot
  end

  def deal_politicians(party)
    politician_deck.shuffle!
    dealt_politicians = []
    (Config.get.politicians_num_in_party - send("hand_#{party}").politicians.count - board.num_encumbents(party)).times do
      dealt_politicians << politician_deck.pop
    end
    dealt_politicians
  end

  def deal_bills(party)
    bill_deck.shuffle!
    dealt_bills = []
    (Config.get.bills_num_in_committee - send("hand_#{party}").bills.count).times do
      dealt_bills << bill_deck.pop
    end
    dealt_bills
  end

  def end_cycle(next_state_of_the_union)
    old_state_of_the_union = board.state_of_the_union
    board.state_of_the_union = next_state_of_the_union
    state_of_the_union_deck.push old_state_of_the_union
  end

end
