require_relative '../base_object'
require_relative 'tactic'

class PlayedTactic < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "party_played_by", type: String, can_be_nil: true },
    { name: "party_played_on", type: String, can_be_nil: true },
    { name: "bill_A",          type: Bill,   can_be_nil: true },
    { name: "bill_B",          type: Bill,   can_be_nil: true },
    { name: "tactic",          type: Tactic },
    { name: "drawn_tactics",   type: Tactic, is_array: true, can_be_nil: true },
  ]

  def can_play(board)
    tactic.preconditions.select do |precondition|
      !precondition.holds(precondition_args(board))
    end.empty?
  end

  def apply_actions(board, legislative_session, boss_A, boss_B)
    tactic.actions.each do |action|
      action.apply(action_args(board, legislative_session, boss_A, boss_B))
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

  def action_args(board, legislative_session, boss_A, boss_B)
    {
      party_played_by: party_played_by,
      party_played_on: party_played_on,
      bill_A: bill_A,
      bill_B: bill_B,
      board: board,
      legislative_session: legislative_session,
      boss_A: boss_A,
      boss_B: boss_B
    }
  end

end
