require_relative '../base_object'
require_relative 'action_params'

class Action < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "action", type: String       },
    { name: "params", type: ActionParams },
  ]

  def apply(args)
    self.send("#{action}", args)
  end
  
  private

  def add_bill_cost(args)
    direction = params.how_many > 0 ? "Increasing" : "Decreasing"
    Logger.log("#{direction} cost of #{target_bill(args)} by #{params.how_many.to_i.abs}")
    old_cost = args[:legislative_session].get_bill_cost(target_bill(args))
    new_cost = args[:legislative_session].change_bill_cost(target_bill(args),
                                                           params.how_many)
    Logger.log("Was #{old_cost}, is now #{new_cost}")
  end

  def add_bill_cost_by_dice(args)
    Logger.log("Rolling #{args[:how_many_dice]} dice to add to cost of #{target_bill(args)}")
    if args[:played_tactic].outcomes.nil?
      args[:played_tactic].outcomes =
        args[:dice_roller].get_outcome(params.how_many_dice)
    end
    Logger.log("Rolled #{args[:played_tactic].outcomes}")
    old_cost = args[:legislative_session].get_bill_cost(target_bill(args))
    new_cost = args[:legislative_session].change_bill_cost(target_bill(args),
                                                           args[:played_tactic].outcomes.sum)
    Logger.log("Was #{old_cost}, is now #{new_cost}")
  end

  def all_dice_count_as(args)
    bill = args[(args[:party_played_on] == 'A') ? :bill_A : :bill_B]
    Logger.log("Making all dice count as #{params.how_many} for #{bill}")
    args[:legislative_session].set_all_dice_count_as(bill, params.how_many)
  end

  def send_dice_to_cloakroom(args)
    Logger.log("Sending all dice but #{params.all_but_how_many} dice to cloakroom for #{target_bill(args)}")
    old_allocation = args[:legislative_session].get_bill_allocation(target_bill(args))
    new_allocation = args[:legislative_session].set_bill_allocation(target_bill(args),
                                                                    [old_allocation, params.all_but_how_many].min)
    Logger.log("Was #{old_allocation}, is now #{new_allocation}")
  end

  def take_cloakroom_dice(args)
    Logger.log("Taking #{params.how_many} dice from cloakroom for #{target_bill(args)}")
    old_allocation = args[:legislative_session].get_bill_allocation(target_bill(args))
    new_allocation = args[:legislative_session].change_bill_allocation(target_bill(args), params.how_many)
    Logger.log("Was #{old_allocation}, is now #{new_allocation}")
  end

  def take_dice_from_opponent(args)
    bill = args[(args[:party_played_by] == 'A') ? :bill_B : :bill_A]
    Logger.log("Taking #{params.how_many} dice from opponent's bill #{bill}")
    old_allocation = args[:legislative_session].get_bill_allocation(bill)
    new_allocation = args[:legislative_session].give_dice_to_opponent(bill,
                                                                      params.how_many)
    Logger.log("Was #{old_allocation}, is now #{new_allocation}")
  end

  def or(args)
    Logger.log("Choosing between #{params.actions.count} actions")
    if args[:played_tactic].or_index.nil?
      args[:played_tactic].or_index = args[(args[:party_played_by] == 'A') ? :boss_A : :boss_B]
                                      .get_choice(params.actions.count)
    end
    params.actions[args[:played_tactic].or_index].apply(args)
  end

  def target_bill(args)
    (params.which.nil? || params.which == "same") ?
      args[(args[:party_played_on] == 'A') ? :bill_A : :bill_B] :
      params.which == "opposite" ?
        args[(args[:party_played_on] == 'A') ? :bill_B : :bill_A] :
        nil
  end

end
