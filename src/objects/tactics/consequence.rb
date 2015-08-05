require_relative '../base_object'
require_relative 'consequence_params'

class Consequence < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "consequence", type: String            },
    { name: "params",      type: ConsequenceParams },
  ]

  def apply(args)
    self.send("#{consequence}", args)
  end

  private

  def add_bill_vps(args)
    Logger.indent.log("")
    party = target_party(args)
    bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
    if args[:legislative_session].
        clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Not adding VPs for #{args[:played_tactic].tactic} on " +
                 "#{bill} due to cloture")
    else
      direction = params.how_many > 0 ? "Increasing" : "Decreasing"
      Logger.log("#{direction} VPs of #{bill} by #{params.how_many.to_i.abs}")
      old_vps = args[:legislative_session].bill_vps(args[:index], party, args[:board])
      new_vps = args[:legislative_session].incr_bill_vps(args[:index], party, args[:board],
                                                         params.how_many)
      Logger.log("Was #{old_vps}, is now #{new_vps}")
    end
    Logger.unindent
  end

  def bill_passes(args)
    Logger.indent.log("")
    party = target_party(args)
    bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
    if args[:legislative_session].
        clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Not auto-passing bill #{bill} due to cloture")
    else
      args[:legislative_session].auto_pass_bill(args[:index], party)
      Logger.log("Auto-passing #{bill}")
    end
    Logger.unindent
  end

  def add_fundraising_dice(args)
    Logger.indent.log("")
    party = target_party(args)
    bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
    if args[:legislative_session].
        clotured?(args[:index], party, args[:played_tactic_index])
      Logger.log("Not adding fundraising dice for #{bill} due to cloture")
    else
      args[:board].add_fundraising_dice(party, params.how_many)
      Logger.log("Party '#{party}' getting #{params.how_many} fundraising dice")
    end
    Logger.unindent
  end

  def target_party(args)
    (params.which.nil? || params.which == 'same') ?
      (args[:party_played_on] == 'A' ? 'A' : 'B') :
      params.which == 'opposite' ?
        (args[:party_played_on] == 'A' ? 'B' : 'A') :
        nil
  end

end
