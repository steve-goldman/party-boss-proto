require_relative 'base_object'
require_relative 'board'
require_relative 'hand'

class GameSnapshot < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :board,  type: Board },
    { name: :hand_A, type: Hand  },
    { name: :hand_B, type: Hand  },
    { name: :politician_deck, type: Politician, is_array: true }
  ]

  # utility method for creating a new game
  def GameSnapshot.new_game
    # create a deck of politicians
    politician_deck = Politician.from_array_file('data/politicians.json').shuffle
    # set the initial office holders from the politician_deck
    office_holders = [
      OfficeHolder.new("A", politician_deck.pop),
      OfficeHolder.new("B", politician_deck.pop),
      OfficeHolder.new("A", politician_deck.pop),
      OfficeHolder.new("B", politician_deck.pop)
    ]
    # create the board
    board = Board.new(StateOfTheUnion.random, office_holders)
    # create the snapshot
    game_snapshot = GameSnapshot.new(board, Hand.new([]), Hand.new([]), politician_deck)
    # deal the cards
    game_snapshot.deal_politicians
    game_snapshot
  end

  def apply_election(election)
    # put the winners in office and losers back in the deck
    election.candidates_A.each_index do |index|
      board.office_holders[index] = OfficeHolder.new board.election_winning_team(election, index), board.election_winner(election, index)
      politician_deck.push board.election_loser(election, index)
    end
    # top off the hands
    deal_politicians
  end
  
  def deal_politicians
    politician_deck.shuffle
    (7 - hand_A.politicians.count - board.num_encumbents('A')).times { hand_A.politicians << politician_deck.pop }
    (7 - hand_B.politicians.count - board.num_encumbents('B')).times { hand_B.politicians << politician_deck.pop }
  end

end
