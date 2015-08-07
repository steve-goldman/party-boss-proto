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

  def after_init
    @passed_bills_cycle_A = []
    @passed_bills_cycle_B = []
    @agenda_level_A = init_agenda_level
    @agenda_level_B = init_agenda_level
    @agenda_bonus_A = 0
    @agenda_bonus_B = 0
  end

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

  def push_passed_bill(party, bill, cur_cycle)
    agenda = bill.agenda.to_sym
    if party == :A
      if has_agenda(passed_bills_A, agenda)
        @agenda_bonus_A += AgendaBonus[@agenda_level_A[agenda]]
        @agenda_level_A[agenda] += 1
      end
      passed_bills_A.push(bill)
      @passed_bills_cycle_A.push(cur_cycle)
    else
      if has_agenda(passed_bills_B, agenda)
        @agenda_bonus_B += AgendaBonus[@agenda_level_B[agenda]]
        @agenda_level_B[agenda] += 1
      end
      passed_bills_B.push(bill)
      @passed_bills_cycle_B.push(cur_cycle)
    end
  end

  def sunsetting_bills_count(party, next_cycle)
    if party == :A
      @passed_bills_cycle_A.reduce(0) do |sum, elem|
        sum + (next_cycle - elem > Config.get.bill_sunset_num_cycles ? 1 : 0)
      end
    else
      @passed_bills_cycle_B.reduce(0) do |sum, elem|
        sum + (next_cycle - elem > Config.get.bill_sunset_num_cycles ? 1 : 0)
      end
    end
  end

  def end_cycle(next_cycle, bill_deck)
    increment_vps(:A, @agenda_bonus_A)
    @agenda_bonus_A = 0
    increment_vps(:B, @agenda_bonus_B)
    @agenda_bonus_B = 0
    
    sunsetting_bills_count(:A, next_cycle).times do
      @agenda_level_A[passed_bills_A[0].agenda.to_sym] = 0
      bill_deck.push(passed_bills_A[0])
      passed_bills_A.delete_at(0)
      @passed_bills_cycle_A.delete_at(0)
    end

    sunsetting_bills_count(:B, next_cycle).times do
      @agenda_level_B[passed_bills_B[0].agenda.to_sym] = 0
      bill_deck.push(passed_bills_B[0])
      passed_bills_B.delete_at(0)
      @passed_bills_cycle_B.delete_at(0)
    end
  end

  def agenda_bonus(party)
    party == :A ? @agenda_bonus_A : @agenda_bonus_B
  end
  
  private

  AgendaBonus = [1, 3, 6, 10, 15, 21, 28]
  
  def office_holder?(candidate)
    !office_holders.select { |office_holder|
      candidate.equals?(office_holder.politician)
    }.empty?
  end

  def init_agenda_level
    {
      conservative: 0,
      libertarian: 0,
      progressive: 0,
      moderate: 0,
      leftist: 0,
    }
  end

  def has_agenda(bills, agenda)
    !bills.select { |bill| bill.agenda.to_sym == agenda }.empty?
  end
end
