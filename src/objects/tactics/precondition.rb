require_relative '../base_object'
require_relative 'params'

class Precondition < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "precondition", type: String },
    { name: "params",       type: Params },
  ]

  def holds(party, my_bill, other_bill, board)
    self.send("#{precondition}", party, my_bill, other_bill, board)
  end

  private
  
  def num_in_office(party, my_bill, other_bill, board)
    target_party = target_party(party)
    count = board.office_holders.reduce(0) do |count, office_holder|
      count + (office_holder.party == target_party ? 1 : 0)
    end
    operate(count, params.how_many)
  end

  def bill_agenda(party, my_bill, other_bill, board)
    target_bill(my_bill, other_bill).agenda == params.agenda
  end

  def target_party(party)
    params.who == 'self' ? party :
      params.who == 'opponent' ? other_party(party) :
        nil
  end

  def target_bill(my_bill, other_bill)
    params.who == 'self' ? my_bill :
      params.who == 'opponent' ? other_bill :
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
