require_relative '../objects/config'
require_relative '../objects/game_state'
require_relative 'logger'

class RandomBoss

  def initialize(party, hand)
    @party = party
    @hand = hand
    @random = Random.new
  end

  def get_candidates(game_state)
    temp_politicians = @hand.politicians.clone
    game_state.board.office_holders.map do |office_holder|
      if @party == office_holder.party.to_sym
        office_holder.politician
      else
        draw_random(temp_politicians)
      end
    end
  end

  def get_bills
    temp_bills = @hand.bills.clone
    Config.get.bills_num_on_floor.times.map do |index|
      draw_random(temp_bills)
    end
  end

  def get_bill(mask_out_bills)
    temp_bills = @hand.bills.select do |bill|
      mask_out_bills.select { |mask_bill| mask_bill.equals?(bill) }.empty?
    end
    draw_random(temp_bills)
  end

  def get_tactic(legislative_session)
    [Tactic::Pass, nil, nil]
  end

  def get_allocation(total_dice, matchup_descriptions)
    # we need (n - 1) fenceposts, which can be overlapping
    fenceposts = (matchup_descriptions.count - 1).times.map do
      @random.rand(total_dice + 1)
    end

    allocation = []
    last_fencepost = 0
    fenceposts.sort.each do |fencepost|
      allocation.push(fencepost - last_fencepost)
      last_fencepost = fencepost
    end
    allocation.push(total_dice - last_fencepost)

    puts "fenceposts: #{fenceposts}, allocation: #{allocation}"

    DiceAllocation.new(allocation)
  end

  def get_choice(options)
    options[@random.rand(options.count)]
  end

  private

  def draw_random(array)
    index = @random.rand(array.count)
    elem = array[index]
    array.delete_at(index)
    elem
  end
  
end
