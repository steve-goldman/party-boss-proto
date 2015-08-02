require "minitest/autorun"

require_relative '../../../src/objects/board'
require_relative '../../../src/objects/tactics/precondition'

class PreconditionTests < Minitest::Test

  def test_num_in_office_tests
    ['A', 'B'].each do |my_party|
      ['self', 'opponent'].each do |who|
        party = target_party(my_party, who)

        precondition = get_num_in_office(who, 2, "eq")
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 1)))
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 2)))
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 3)))

        precondition = get_num_in_office(who, 2, "gt")
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 1)))
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 2)))
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 3)))

        precondition = get_num_in_office(who, 2, "gte")
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 1)))
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 2)))
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 3)))

        precondition = get_num_in_office(who, 2, "lt")
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 1)))
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 2)))
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 3)))

        precondition = get_num_in_office(who, 2, "lte")
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 1)))
        assert  precondition.holds(args(my_party, nil, nil, nil, get_board(party, 2)))
        assert !precondition.holds(args(my_party, nil, nil, nil, get_board(party, 3)))
      end
    end
  end

  def test_bill_agenda
    precondition = get_bill_agenda('self', 'conservative')
    assert  precondition.holds(args('A', 'A', get_bill('conservative'), nil, nil))
    assert !precondition.holds(args('A', 'A', get_bill('moderate'),     nil, nil))

    precondition = get_bill_agenda('opponent', 'conservative')
    assert  precondition.holds(args('A', 'B', nil, get_bill('conservative'), nil))
    assert !precondition.holds(args('A', 'B', nil, get_bill('moderate'),     nil))
  end

  def test_or
    assert !get_or([get_always_false, get_always_false]).holds(args(nil, nil, nil, nil, nil))
    assert  get_or([get_always_true,  get_always_false]).holds(args(nil, nil, nil, nil, nil))
    assert  get_or([get_always_false, get_always_true ]).holds(args(nil, nil, nil, nil, nil))
    assert  get_or([get_always_true,  get_always_true ]).holds(args(nil, nil, nil, nil, nil))
  end

  def test_played_on_party
    assert  get_played_on_party('self').holds(args('A', 'A', nil, nil, nil))
    assert !get_played_on_party('self').holds(args('A', 'B', nil, nil, nil))
    assert  get_played_on_party('opponent').holds(args('A', 'B', nil, nil, nil))
    assert !get_played_on_party('opponent').holds(args('A', 'A', nil, nil, nil))
  end

  private

  def args(party_played_by, party_played_on, bill_A, bill_B, board)
    {
      party_played_by: party_played_by,
      party_played_on: party_played_on,
      bill_A: bill_A,
      bill_B: bill_B,
      board: board,
    }
  end

  def target_party(my_party, who)
    party = (who == 'self') ? my_party : other_party(my_party)
  end

  def get_num_in_office(who, how_many, operator)
    Precondition.new("num_in_office", PreconditionParams.new(who,
                                                             nil,
                                                             how_many,
                                                             operator,
                                                             nil))
  end

  def get_or(preconditions)
    Precondition.new("or", PreconditionParams.new(nil, nil, nil, nil,
                                                  preconditions))
  end

  def get_played_on_party(who)
    Precondition.new("played_on_party", PreconditionParams.new(who,
                                                               nil, nil, nil, nil))
  end

  def get_bill_agenda(who, agenda)
    Precondition.new("bill_agenda", PreconditionParams.new(who,
                                                           agenda,
                                                           nil, nil, nil))
  end

  def get_always_true
    dummy_precondition('always_true')
  end

  def get_always_false
    dummy_precondition('always_false')
  end

  def dummy_precondition(name)
    Precondition.new(name, PreconditionParams.new(nil, nil, nil, nil, nil))
  end

  def get_board(party, count)
    office_holders = count.times.map { OfficeHolder.new(party, nil) }
    Board.new(nil, office_holders, nil, nil, nil, nil, nil)
  end

  def get_bill(agenda)
    Bill.new(nil, agenda, nil, nil)
  end

  def other_party(party)
    party == 'A' ? 'B' : 'A'
  end
end
