require_relative '../objects/dice_allocation'
require_relative '../objects/dice_outcome'

class DiceRoller

  def initialize
    @random = Random.new
  end
  
  def get_outcomes(allocation)
    allocation.counts.map do |count|
      DiceOutcome.new Array.new(count).map { @random.rand(3) }
    end
  end
  
end
