require_relative '../base_object'
require_relative 'tactic'

class PlayedTactic < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "party_played_by", type: String,       can_be_nil: true },
    { name: "party_played_on", type: String,       can_be_nil: true },
    { name: "bill_A",          type: Bill,         can_be_nil: true },
    { name: "bill_B",          type: Bill,         can_be_nil: true },
    { name: "tactic",          type: Tactic },
    { name: "drawn_tactic",    type: Tactic,       can_be_nil: true },
    { name: "outcomes",        type: DiceOutcome,  can_be_nil: true },
    { name: "or_index",        type: Integer,      can_be_nil: true },
  ]

  def can_play(board)
    tactic.preconditions.select do |precondition|
      !precondition.holds(precondition_args(board))
    end.empty?
  end

  def apply_actions(board, legislative_session, boss_A, boss_B, dice_roller)
    tactic.actions.each do |action|
      action.apply(action_args(board, legislative_session, boss_A, boss_B, dice_roller))
    end
  end

  private

  def precondition_args(board)
    {
      party_played_by: party_played_by,
      party_played_on: party_played_on,
      bill_A: bill_A,
      bill_B: bill_B,
      board: board,
    }
  end

  def action_args(board, legislative_session, boss_A, boss_B, dice_roller)
    {
      party_played_by: party_played_by,
      party_played_on: party_played_on,
      bill_A: bill_A,
      bill_B: bill_B,
      board: board,
      legislative_session: legislative_session,
      boss_A: boss_A,
      boss_B: boss_B,
      played_tactic: self,
      dice_roller: dice_roller,
    }
  end

end
