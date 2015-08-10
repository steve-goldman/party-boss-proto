module TacticsCommon

  def target_party(args)
    params.which.nil? || params.which == 'same' ?
      (args[:party_played_on] == :A ? :A : :B) :
      params.which == 'opposite' ?
        (args[:party_played_on] == :A ? :B : :A) :
        nil
  end

  def add_bill_vps(args)
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party)
      "Moot due to cloture"
    else
      direction = params.how_many > 0 ? "Increasing" : "Decreasing"
      bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
      old_vps = args[:legislative_session].bill_vps(args[:index], party, args[:board])
      new_vps = args[:legislative_session].incr_bill_vps(args[:index], party, args[:board],
                                                         params.how_many)
      [
        "#{direction} VPs of #{bill} by #{params.how_many.to_i.abs}",
        "Was #{old_vps}, is now #{new_vps}",
      ].join("\n")
    end
  end

  def other_party(party)
    party == :A ? :B : :A
  end

  def bill_auto_passes(args)
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party)
      "Moot due to cloture"
    else
      bill = args[:legislative_session].get_bill_on_floor(args[:index], party)
      args[:legislative_session].auto_pass_bill(args[:index], party)
      "Auto-passing #{bill}"
    end
  end

end
