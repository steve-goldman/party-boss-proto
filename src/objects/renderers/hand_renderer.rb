require_relative '../hand'

class HandRenderer < Renderer

  Passes = "PASSES"
  DoesNotPass = "DOES NOT PASS"
  
  def initialize
    super(
      [
        Politician::MaxLength,
        Bill::MaxLength,
        Tactic::MaxLength
      ].max / 2 - 1
    )
  end
  
  @@instance = nil

  def HandRenderer.get
    @@instance = HandRenderer.new if @@instance.nil?
    @@instance
  end
  
  def render(hand)
    [
      candidates(hand), underline,
      bills(hand),      underline,
      tactics(hand)
    ].join("\n")
  end

  private

  def candidates(hand)
    [
      "Candidates", underline,
    ]
      .concat(hand.politicians.map { |politician| "#{politician}" })
      .join("\n")
  end

  def bills(hand)
    [
      "Bills", underline,
    ]
      .concat(hand.bills.map { |bill| "#{bill}" })
      .join("\n")
  end

  def tactics(hand)
    [
      "Tactics", underline,
    ]
      .concat(hand.tactics.map { |tactic| "#{tactic}" })
      .join("\n")
  end


end
