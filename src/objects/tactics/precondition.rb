require_relative '../base_object'
require_relative 'precondition_params'

class Precondition < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "precondition", type: String             },
    { name: "params",       type: PreconditionParams },
  ]

  def holds(args)
    self.send("#{precondition}", args)
  end

  private
  
  def played_on_party(args)
    params.who == 'self' ?
      args[:party_played_by] == args[:party_played_on] :
      args[:party_played_by] != args[:party_played_on]
  end

  def num_in_office(args)
    count = args[:board].office_holders.reduce(0) do |count, office_holder|
      count + (office_holder.party == target_party(args) ? 1 : 0)
    end
    operate(count, params.how_many)
  end

  def bill_agenda(args)
    target_bill(args).agenda == params.agenda
  end

  def or(args)
    params.preconditions.each do |precondition|
      return true if precondition.holds(args)
    end
    false
  end

  # used in unit tests
  def always_true(args)
    true
  end

  # used in unit tests
  def always_false(args)
    false
  end

  def target_party(args)
    params.who == 'self' ? args[:party_played_by] :
      params.who == 'opponent' ? other_party(args) :
        nil
  end

  def target_bill(args)
    params.who == 'self' ? (args[:party_played_by] == 'A' ?
                              args[:bill_A] : args[:bill_B]) :
      params.who == 'opponent' ? (args[:party_played_by] == 'A' ?
                                    args[:bill_B] : args[:bill_A]) :
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
  
  def other_party(args)
    args[:party_played_by] == 'A' ? 'B' : 'A'
  end
end
