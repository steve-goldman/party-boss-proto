require_relative '../objects/dice_allocation'
require_relative '../objects/dice_outcome'

class DiceRoller

  def initialize
    @random = Random.new
  end
  
  def get_outcomes(allocation, all_dice_outcomes = nil)
    allocation.counts.each_index.map do |index|
      get_outcome(allocation.counts[index], all_dice_outcomes.nil? ? -1 : all_dice_outcomes[index])
    end
  end

  def get_outcome(count, all_dice_outcomes)
    all_dice_outcomes < 0 ?
      DiceOutcome.new(Array.new(count).map { @random.rand(3)   }) :
      DiceOutcome.new(Array.new(count).map { all_dice_outcomes })
  end
  
end
