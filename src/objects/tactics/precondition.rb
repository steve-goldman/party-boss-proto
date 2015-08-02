require_relative '../base_object'
require_relative 'precondition_params'

class Precondition < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "precondition", type: String             },
    { name: "params",       type: PreconditionParams },
  ]

  def holds(party, played_on_party, bill_A, bill_B, board)
    self.send("#{precondition}", party, played_on_party, bill_A, bill_B, board)
  end

  private
  
  def played_on_party(party, played_on_party, bill_A, bill_B, board)
    params.who == 'self' ? party == played_on_party : party != played_on_party
  end

  def num_in_office(party, played_on_party, bill_A, bill_B, board)
    target_party = target_party(party)
    count = board.office_holders.reduce(0) do |count, office_holder|
      count + (office_holder.party == target_party ? 1 : 0)
    end
    operate(count, params.how_many)
  end

  def bill_agenda(party, played_on_party, bill_A, bill_B, board)
    target_bill(party, played_on_party, bill_A, bill_B).agenda == params.agenda
  end

  def or(party, played_on_party, bill_A, bill_B, board)
    params.preconditions.each do |precondition|
      return true if precondition.holds(party, played_on_party, bill_A, bill_B, board)
    end
    false
  end

  # used in unit tests
  def always_true(party, played_on_party, bill_A, bill_B, board)
    true
  end

  # used in unit tests
  def always_false(party, played_on_party, bill_A, bill_B, board)
    false
  end

  def target_party(party)
    params.who == 'self' ? party :
      params.who == 'opponent' ? other_party(party) :
        nil
  end

  def target_bill(party, played_on_party, bill_A, bill_B)
    params.who == 'self' ? (party == 'A' ? bill_A : bill_B) :
      params.who == 'opponent' ? (party == 'A' ? bill_B : bill_A) :
        nil
  end

  def operate(operand_A, operand_B)
    if params.operator == "gte"
      operand_A >= operand_B
    elsif params.operator == "gt"
      operand_A > operand_B
    elsif params.operator == "lte"
      operand_A <= operand_B
    elsif params.operator == "lt"
      operand_A < operand_B
    elsif params.operator == "eq"
      operand_A == operand_B
    end
  end
  
  def other_party(party)
    party == 'A' ? 'B' : 'A'
  end
end
