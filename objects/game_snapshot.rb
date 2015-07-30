require_relative 'base_object'
require_relative 'config'
require_relative 'board'
require_relative 'hand'

class GameSnapshot < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :board,  type: Board },
    { name: :hand_A, type: Hand  },
    { name: :hand_B, type: Hand  },
    { name: :politician_deck, type: Politician, is_array: true },
    { name: :bill_deck,       type: Bill,       is_array: true },
  ]

  # utility method for creating a new game
  def GameSnapshot.new_game
    # create the decks of politicians
    politician_deck = Politician.from_array_file('data/politicians.json')
    bill_deck = Bill.from_array_file('data/bills.json')
    # set the initial office holders from the politician_deck
    office_holders = []
    Config.get.seats_num.times do
      office_holders << OfficeHolder.new(office_holders.count % 2 == 0 ? 'A' : 'B', politician_deck.pop)
    end
    # create the board
    board = Board.new(StateOfTheUnion.random, office_holders)
    # create the snapshot
    game_snapshot = GameSnapshot.new(board, Hand.new([], []), Hand.new([], []), politician_deck, bill_deck)
    # deal the cards
    game_snapshot.deal_politicians
    game_snapshot.deal_bills
    game_snapshot
  end

  def apply_election(election)
    # put the winners in office and losers back in the deck
    Config.get.seats_num.times do |index|
      result = election.get_result index, board
      board.office_holders[index] = OfficeHolder.new result[:winning_party], result[:winner]
      politician_deck.push result[:loser]
    end
    # top off the hands
    deal_politicians
  end
  
  def deal_politicians
    politician_deck.shuffle
    (Config.get.politicians_num_in_party - hand_A.politicians.count - board.num_encumbents('A')).times do
      hand_A.politicians << politician_deck.pop
    end
    (Config.get.politicians_num_in_party - hand_B.politicians.count - board.num_encumbents('B')).times do
      hand_B.politicians << politician_deck.pop
    end
  end

  def deal_bills
    bill_deck.shuffle
    for hand in [ hand_A, hand_B ] do
      (Config.get.bills_num_in_committee - hand.bills.count).times do
        hand.bills << bill_deck.pop
      end
    end
  end

end
