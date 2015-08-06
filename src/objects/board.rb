require_relative 'base_object'
require_relative 'state_of_the_union'
require_relative 'office_holder'
require_relative 'bill'

class Board < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "state_of_the_union", type: StateOfTheUnion              },
    { name: "office_holders",     type: OfficeHolder, is_array: true },
    { name: "tactics_lead_party", type: String                       },
    { name: "passed_bills_A",     type: Bill,         is_array: true },
    { name: "passed_bills_B",     type: Bill,         is_array: true },
    { name: "hard_vps_A",         type: Integer                      },
    { name: "hard_vps_B",         type: Integer                      },
    { name: "fundraising_dice_A", type: Integer                      },
    { name: "fundraising_dice_B", type: Integer                      },
  ]

  def num_encumbents(party)
    office_holders.reduce(0) do |sum, office_holder|
      sum + (office_holder.party == party ? 1 : 0)
    end
  end

  def num_fundraising_dice(party, candidates)
    [
      [
        Config.get.fundraising_dice_max,
        send("fundraising_dice_#{party}") +
        candidates.reduce(0) { |sum, candidate|
          sum + candidate.fundraising + (office_holder?(candidate) ? 1 : 0)
        }
      ].min,
      0
    ].max
  end

  def num_leadership_dice(party)
    [
      Config.get.leadership_dice_max,
      office_holders.reduce(0) { |sum, office_holder|
        if office_holder.party.to_sym == party
          sum + office_holder.politician.strengths.total
        else
          sum
        end
      }
    ].min
  end

  def vps_A
    hard_vps_A
  end
  
  def vps_B
    hard_vps_B
  end

  def increment_vps(party, vps)
    party == :A ?
      self.hard_vps_A = hard_vps_A.to_i + vps :
      self.hard_vps_B = hard_vps_B.to_i + vps
  end

  def add_fundraising_dice(party, delta)
    party == :A ?
      self.fundraising_dice_A += delta :
      self.fundraising_dice_B += delta
  end
  
  private

  def office_holder?(candidate)
    !office_holders.select { |office_holder|
      candidate.equals?(office_holder.politician)
    }.empty?
  end

end
