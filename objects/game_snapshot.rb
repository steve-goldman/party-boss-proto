require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'board'
require_relative 'hand'

class GameSnapshot

  # define the data that goes in this object
  Members = [
    { name: :board,  type: Board },
    { name: :hand_A, type: Hand  },
    { name: :hand_B, type: Hand  },
    { name: :politician_deck, type: Politician, is_array: true }
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def my_hand(player)
    self.send("hand_#{player.team}")
  end

  # utility method for creating a new game
  def GameSnapshot.new_game
    # create a deck of politicians
    politicians_deck = Politician.from_array_file('data/politicians.json').shuffle
    # set the initial office holders from the politicians_deck
    office_holders = [
      OfficeHolder.new("A", politicians_deck.pop),
      OfficeHolder.new("B", politicians_deck.pop),
      OfficeHolder.new("A", politicians_deck.pop),
      OfficeHolder.new("B", politicians_deck.pop)
    ]
    # create the board
    board = Board.new(office_holders)
    # create two hands
    hand_A = Hand.new([ politicians_deck.pop, politicians_deck.pop ])
    hand_B = Hand.new([ politicians_deck.pop, politicians_deck.pop ])
    # finally, create the snapshot
    GameSnapshot.new(board, hand_A, hand_B, politicians_deck)
  end

end
