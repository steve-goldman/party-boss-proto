require "minitest/autorun"

require_relative '../../../src/objects/board'
require_relative '../../../src/objects/tactics/precondition'

class PreconditionTests < Minitest::Test

  def test_num_in_office_tests
    ['A', 'B'].each do |my_party|
      ['self', 'opponent'].each do |who|
        party = target_party(my_party, who)

        precondition = get_num_in_office(who, 2, "eq")
        assert !precondition.holds(my_party, nil, nil, get_board(party, 1))
        assert  precondition.holds(my_party, nil, nil, get_board(party, 2))
        assert !precondition.holds(my_party, nil, nil, get_board(party, 3))

        precondition = get_num_in_office(who, 2, "gt")
        assert !precondition.holds(my_party, nil, nil, get_board(party, 1))
        assert !precondition.holds(my_party, nil, nil, get_board(party, 2))
        assert  precondition.holds(my_party, nil, nil, get_board(party, 3))

        precondition = get_num_in_office(who, 2, "gte")
        assert !precondition.holds(my_party, nil, nil, get_board(party, 1))
        assert  precondition.holds(my_party, nil, nil, get_board(party, 2))
        assert  precondition.holds(my_party, nil, nil, get_board(party, 3))

        precondition = get_num_in_office(who, 2, "lt")
        assert  precondition.holds(my_party, nil, nil, get_board(party, 1))
        assert !precondition.holds(my_party, nil, nil, get_board(party, 2))
        assert !precondition.holds(my_party, nil, nil, get_board(party, 3))

        precondition = get_num_in_office(who, 2, "lte")
        assert  precondition.holds(my_party, nil, nil, get_board(party, 1))
        assert  precondition.holds(my_party, nil, nil, get_board(party, 2))
        assert !precondition.holds(my_party, nil, nil, get_board(party, 3))
      end
    end
  end

  def test_bill_agenda
    precondition = get_bill_agenda('self', 'conservative')
    assert  precondition.holds(nil, get_bill('conservative'), nil, nil)
    assert !precondition.holds(nil, get_bill('moderate'),     nil, nil)

    precondition = get_bill_agenda('opponent', 'conservative')
    assert  precondition.holds(nil, nil, get_bill('conservative'), nil)
    assert !precondition.holds(nil, nil, get_bill('moderate'),     nil)
  end

  def target_party(my_party, who)
    party = (who == 'self') ? my_party : other_party(my_party)
  end

  private

  def get_num_in_office(who, how_many, operator)
    Precondition.new("num_in_office", Params.new(who,
                                                 nil,
                                                 how_many,
                                                 operator))
  end

  def get_bill_agenda(who, agenda)
    Precondition.new("bill_agenda", Params.new(who,
                                               agenda,
                                               nil, nil))
  end
  
  def get_board(party, count)
    office_holders = count.times.map { OfficeHolder.new(party, nil) }
    Board.new(nil, office_holders, nil, nil, nil, nil)
  end

  def get_bill(agenda)
    Bill.new(nil, agenda, nil, nil)
  end

  def other_party(party)
    party == 'A' ? 'B' : 'A'
  end
end
