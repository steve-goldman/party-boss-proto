require_relative 'base_object'
require_relative 'state_of_the_union'
require_relative 'office_holder'
require_relative 'bill'

class Board < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "state_of_the_union", type: StateOfTheUnion              },
    { name: "office_holders",     type: OfficeHolder, is_array: true },
    { name: "passed_bills_A",     type: Bill,         is_array: true },
    { name: "passed_bills_B",     type: Bill,         is_array: true },
    { name: "hard_vps_A",         type: Integer                      },
    { name: "hard_vps_B",         type: Integer                      },
  ]

  def num_encumbents(party)
    office_holders.reduce(0) do |sum, office_holder|
      sum + (office_holder.party == party ? 1 : 0)
    end
  end

  def num_fundraising_dice(candidates)
    [
      Config.get.fundraising_dice_max,
      candidates.reduce(0) { |sum, candidate|
        sum + candidate.fundraising + (office_holder?(candidate) ? 1 : 0)
      }
    ].min
  end

  def num_legislative_dice(party)
    [
      Config.get.legislative_dice_max,
      office_holders.reduce(0) { |sum, office_holder|
        if office_holder.party == party
          sum + office_holder.politician.strengths.total
        else
          sum
        end
      }
    ].min
  end

  def description
    [
      "The state of the union: #{state_of_the_union}", underline,
      desc_party_header,   underline,
      desc_office_holders, underline,
      desc_vps,            underline,
      desc_passed_bills,   underline,
    ].join("\n")
  end

  def vps_A
    hard_vps_A
  end
  
  def vps_B
    hard_vps_B
  end

  def increment_vps(party, vps)
    hard_vps_A = hard_vps_A.to_i + vps
  end
  
  private

  DescSideLength = [Politician::MaxLength, Bill::MaxLength].max
  DescLength = 2 * DescSideLength + 3

  def office_holder?(candidate)
    !office_holders.select { |office_holder|
      candidate.equals?(office_holder.politician)
    }.empty?
  end

  def desc_office_holders
    [
      "Politicians holding office",
      underline
    ]
      .concat(Config.get.seats_num.times.map { |index|
                desc_two_sides(office_holders[index].party == 'A' ? office_holders[index].politician : "",
                               office_holders[index].party == 'B' ? office_holders[index].politician : "")})
      .join("\n")
  end

  def desc_vps
    [
      "Victory Points",
      underline,
      desc_two_sides(vps_A, vps_B),
    ].join("\n")
  end
  
  def desc_passed_bills
    [
      "Passed bills",
      underline,
    ]
      .concat([passed_bills_A.count, passed_bills_B.count].max.times.map { |index|
                desc_two_sides(passed_bills_A.count > index ? passed_bills_A[index] : "",
                               passed_bills_B.count > index ? passed_bills_B[index] : "")})
      .join("\n")
  end

  def desc_party_header
    desc_two_sides 'Party A', 'Party B'
  end

  def underline
    "-" * DescLength
  end

  def desc_two_sides(left, right)
    sprintf("%-#{DescSideLength}s | %-#{DescSideLength}s", left, right)
  end
end
