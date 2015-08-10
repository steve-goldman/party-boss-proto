require_relative '../base_object'
require_relative 'precondition_params'
require_relative 'tactics_common'

class Precondition < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "precondition", type: String             },
    { name: "params",       type: PreconditionParams },
  ]

  def holds(args)
    return false if
      args[:legislative_session].clotured?(args[:index], args[:party_played_on])
    self.send("#{precondition}", args)
  end

  private
  
  include TacticsCommon
  
  def played_on_party(args)
    params.who == 'self' ?
      args[:party_played_by] == args[:party_played_on] :
      args[:party_played_by] != args[:party_played_on]
  end

  def opposite_not_clotured(args)
    !args[:legislative_session].clotured?(args[:index], other_party(args[:party_played_on]))
  end

  def num_in_office(args)
    count = args[:board].office_holders.reduce(0) do |count, office_holder|
      count + (office_holder.party.to_sym == target_party(args) ? 1 : 0)
    end
    operate(count, params.how_many)
  end

  def bill_agenda(args)
    target_bill(args).agenda == params.agenda
  end

  def bill_passes(args)
    passes = !args[:legislative_session].passes?(args[:index], target_party(args)).nil?
    passes ? (params.passes.nil? || params.passes == "true") : params.passes == "false"
  end

  def bill_rolls_minus_cost(args)
    operate(args[:legislative_session].send("outcomes_#{target_party(args)}")[args[:index]].sum -
            args[:legislative_session].bill_cost(args[:index], target_party(args)),
            params.how_many)
  end

  def has_allocated_dice(args)
    args[:legislative_session].get_bill_allocation(args[:index], target_party(args)) >=
      params.how_many
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

  def target_bill(args)
    args[:legislative_session].get_bill_on_floor(args[:index], target_party(args))
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
  
end
