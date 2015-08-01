require_relative '../base_object'
require_relative 'params'

class Precondition < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "precondition", type: String },
    { name: "params",       type: Params },
  ]

  def holds(party, is_my_bill, bill_A, bill_B, board)
    self.send("#{precondition}", party, is_my_bill, bill_A, bill_B, board)
  end

  private
  
  def num_in_office(party, is_my_bill, bill_A, bill_B, board)
    target_party = params.who == 'self' ?
                     party : params.who == "opponent" ?
                               other_party(party) : nil
    count = board.office_holders.reduce(0) do |count, office_holder|
      count + (office_holder.party == target_party ? 1 : 0)
    end
    operate(count, params.how_many, params.operator)
  end

  def operate(operand_A, operand_B, operator)
    if operator == "gte"
      operand_A >= operand_B
    elsif operator == "gt"
      operand_A > operand_B
    elsif operator == "lte"
      operand_A <= operand_B
    elsif operator == "lt"
      operand_A < operand_B
    elsif operator == "eq"
      operand_A == operand_B
    end
  end
  
  def other_party(party)
    party == 'A' ? 'B' : 'A'
  end
end
