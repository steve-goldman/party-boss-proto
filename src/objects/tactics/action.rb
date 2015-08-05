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
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Moot due to cloture")
    else
      direction = params.how_many > 0 ? "Increasing" : "Decreasing"
      bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
      Logger.log("#{direction} cost of #{bill} by #{params.how_many.to_i.abs}")
      old_cost = args[:legislative_session].bill_cost(args[:index], party)
      new_cost = args[:legislative_session].incr_bill_cost(args[:index], party,
                                                           params.how_many)
      Logger.log("Was #{old_cost}, is now #{new_cost}")
    end
  end

  def add_bill_cost_by_dice(args)
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Moot due to cloture")
    else
      bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
      Logger.log("Rolling #{args[:how_many_dice]} dice to add to cost of #{bill}")
      if args[:played_tactic].outcomes.nil?
        args[:played_tactic].outcomes =
          args[:dice_roller].get_outcome(params.how_many_dice)
      end
      Logger.log("Rolled #{args[:played_tactic].outcomes}")
      old_cost = args[:legislative_session].bill_cost(args[:index], party)
      new_cost = args[:legislative_session].incr_bill_cost(args[:index], party,
                                                           args[:played_tactic].outcomes.sum)
      Logger.log("Was #{old_cost}, is now #{new_cost}")
    end
  end

  def all_dice_count_as(args)
    if args[:legislative_session].clotured?(args[:index], args[:party_played_by], args[:played_tactic_index])
      Logger.log("Moot due to cloture")
    else
      bill = args[:legislative_session].get_bill_on_floor(args[:index], args[:party_played_on])
      Logger.log("Making all dice count as #{params.how_many} for #{bill}")
      args[:legislative_session].set_all_dice_count_as(args[:index], args[:party_played_on], params.how_many)
    end
  end

  def send_dice_to_cloakroom(args)
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Moot due to cloture")
    else
      bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
      Logger.log("Sending all dice but #{params.all_but_how_many} dice to cloakroom for #{bill}")
      old_allocation = args[:legislative_session].get_bill_allocation(args[:index], party)
      new_allocation = args[:legislative_session].set_bill_allocation(args[:index], party,
                                                                      [old_allocation, params.all_but_how_many].min)
      Logger.log("Was #{old_allocation}, is now #{new_allocation}")
    end
  end

  def take_cloakroom_dice(args)
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Moot due to cloture")
    else
      bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
      Logger.log("Taking #{params.how_many} dice from cloakroom for #{bill}")
      old_allocation = args[:legislative_session].get_bill_allocation(args[:index], party)
      new_allocation = args[:legislative_session].change_bill_allocation(args[:index], party, params.how_many)
      Logger.log("Was #{old_allocation}, is now #{new_allocation}")
    end
  end

  def take_dice_from_opponent(args)
    opponent_party = args[:party_played_by] == 'A' ? 'B' : 'A'
    if args[:legislative_session].clotured?(args[:index], args[:party_played_by], args[:played_tactic_index]) ||
       args[:legislative_session].clotured?(args[:index], opponent_party, args[:played_tactic_index])
      Logger.log("Moot due to cloture")
    else
      bill = args[:legislative_session].get_bill_on_floor(args[:index], opponent_party)
      Logger.log("Taking #{params.how_many} dice from opponent's bill #{bill}")
      old_allocation = args[:legislative_session].get_bill_allocation(args[:index], opponent_party)
      new_allocation = args[:legislative_session].give_dice_to_opponent(args[:index], opponent_party,
                                                                        params.how_many)
      Logger.log("Was #{old_allocation}, is now #{new_allocation}")
    end
  end

  def or(args)
    Logger.log("Choosing between #{params.actions.count} actions")
    if args[:played_tactic].or_index.nil?
      args[:played_tactic].or_index = args[(args[:party_played_by] == 'A') ? :boss_A : :boss_B]
                                      .get_choice(params.actions.count)
    end
    params.actions[args[:played_tactic].or_index].apply(args)
  end

  def target_party(args)
    (params.which.nil? || params.which == 'same') ?
      (args[:party_played_on] == 'A' ? 'A' : 'B') :
      params.which == 'opposite' ?
        (args[:party_played_on] == 'A' ? 'B' : 'A') :
        nil
  end

end
