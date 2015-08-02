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

end
