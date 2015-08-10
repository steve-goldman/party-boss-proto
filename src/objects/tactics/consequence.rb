require_relative '../base_object'
require_relative 'tactics_common'
require_relative 'consequence_params'

class Consequence < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "consequence", type: String            },
    { name: "params",      type: ConsequenceParams },
  ]

  def apply(args)
    preconditions_hold =
      params.preconditions.nil? ||
      params.preconditions.select { |precondition| !precondition.holds(args) }.empty?
    self.send("#{consequence}", args) if preconditions_hold
  end

  private

  include TacticsCommon

  def add_fundraising_dice(args)
    party = target_party(args)
    if args[:legislative_session].clotured?(args[:index], party)
      "Moot due to cloture"
    else
      args[:board].add_fundraising_dice(party, params.how_many)
      "Party '#{party}' getting #{params.how_many} fundraising dice"
    end
  end

end
