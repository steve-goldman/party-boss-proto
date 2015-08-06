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
    party = target_party(args)
    bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
    if args[:legislative_session].
        clotured?(args[:index], party, args[:played_tactic_index])
      "Moot due to cloture"
    else
      direction = params.how_many > 0 ? "Increasing" : "Decreasing"
      old_vps = args[:legislative_session].bill_vps(args[:index], party, args[:board])
      new_vps = args[:legislative_session].incr_bill_vps(args[:index], party, args[:board],
                                                         params.how_many)
      [
        "#{direction} VPs of #{bill} by #{params.how_many.to_i.abs}",
        "Was #{old_vps}, is now #{new_vps}",
      ].join("\n")
    end
  end

  def bill_auto_passes(args)
    party = target_party(args)
    bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
    if args[:legislative_session].
        clotured?(args[:index], party, args[:played_tactic_index])
      "Moot due to cloture"
    else
      args[:legislative_session].auto_pass_bill(args[:index], party)
      "Auto-passing #{bill}"
    end
  end

  def add_fundraising_dice(args)
    party = target_party(args)
    bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
    if args[:legislative_session].
        clotured?(args[:index], party, args[:played_tactic_index])
      "Moot due to cloture"
    else
      args[:board].add_fundraising_dice(party, params.how_many)
      "Party '#{party}' getting #{params.how_many} fundraising dice"
    end
  end

  def target_party(args)
    (params.which.nil? || params.which == 'same') ?
      (args[:party_played_on] == 'A' ? 'A' : 'B') :
      params.which == 'opposite' ?
        (args[:party_played_on] == 'A' ? 'B' : 'A') :
        nil
  end

end
