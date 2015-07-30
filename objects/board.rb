require_relative 'base_object'
require_relative 'state_of_the_union'
require_relative 'office_holder'

class Board < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "state_of_the_union", type: StateOfTheUnion },
    { name: "office_holders",     type: OfficeHolder, is_array: true },
  ]

  def num_campaign_dice(candidates)
    candidates.reduce(0) do |sum, candidate|
      sum + candidate.fundraising + (office_holder?(candidate) ? 1 : 0)
    end
  end

  def num_encumbents(party)
    office_holders.reduce(0) do |sum, office_holder|
      sum + (office_holder.party == party ? 1 : 0)
    end
  end

  def description
    office_holders_array = []
    Config.get.seats_num.times do |index|
      office_holders_array << sprintf("%-#{Politician::MaxLength}s | %-#{Politician::MaxLength}s",
                                      office_holders[index].party == 'A' ? office_holders[index].politician : "",
                                      office_holders[index].party == 'B' ? office_holders[index].politician : "")
    end
    [
      "The state of the union: #{state_of_the_union}",
      "",
      "Politicians holding office",
      "-" * (2 * Politician::MaxLength + 3),
      sprintf("%-#{Politician::MaxLength}s | %-#{Politician::MaxLength}s", "Party 'A'", "Party 'B'"),
      "-" * (2 * Politician::MaxLength + 3),
    ].concat(office_holders_array).join("\n")
  end
  
  private

  def office_holder?(candidate)
    office_holders.reduce(false) do |result, office_holder|
      result || candidate == office_holder.politician
    end 
  end
  
end
