require_relative '../base_object'
require_relative 'tactic'

class PlayedTactic < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "party_played_by",  type: String,       can_be_nil: true },
    { name: "party_played_on",  type: String,       can_be_nil: true },
    { name: "index",            type: Integer,      can_be_nil: true },
    { name: "tactic",           type: Tactic                         },
    { name: "drawn_tactic",     type: Tactic,       can_be_nil: true },
    { name: "replacement_bill", type: Bill,         can_be_nil: true },
    { name: "outcomes",         type: DiceOutcome,  can_be_nil: true },
    { name: "or_index",         type: Integer,      can_be_nil: true },
  ]

  def to_s
    by_section = "#{tactic} played by '#{party_played_by}'"
    on_section = !party_played_on.nil? ? " on '#{party_played_on}'" : ""
    index_section = !index.nil? ? " on session #{index + 1}" : ""
    "#{by_section}#{on_section}#{index_section}"
  end

  def can_play(board, legislative_session)
    tactic.preconditions.select do |precondition|
      !precondition.holds(precondition_args(board, legislative_session))
    end.empty?
  end

  def apply_preactions(legislative_session, game_state, boss_A, boss_B)
    nil
  end

  def apply_actions(legislative_session, game_state, boss_A, boss_B, dice_roller)
    if !tactic.actions.empty?
      tactic.actions.map { |action|
        action.apply(action_args(legislative_session, game_state, boss_A, boss_B, dice_roller))
      }.select { |elem| !elem.nil? }.join("\n")
    else
      nil
    end
  end

  def apply_consequences(board, legislative_session)
    if !tactic.consequences.empty?
      tactic.consequences.map { |consequence|
        consequence.apply(consequence_args(board, legislative_session))
      }.select { |elem| !elem.nil? }.join("\n")
    else
      nil
    end
  end

  def immediate?
    false
  end

  private

  def precondition_args(board, legislative_session)
    {
      party_played_by: party_played_by.to_sym,
      party_played_on: party_played_on.to_sym,
      index: index,
      board: board,
      legislative_session: legislative_session,
      played_tactic: self,
    }
  end

  def action_args(legislative_session, game_state, boss_A, boss_B, dice_roller)
    {
      party_played_by: party_played_by.to_sym,
      party_played_on: party_played_on ? party_played_on.to_sym : nil,
      index: index,
      board: game_state.board,
      game_state: game_state,
      legislative_session: legislative_session,
      boss_A: boss_A,
      boss_B: boss_B,
      played_tactic: self,
      dice_roller: dice_roller,
    }
  end

  def consequence_args(board, legislative_session)
    {
      party_played_by: party_played_by.to_sym,
      party_played_on: party_played_on.to_sym,
      index: index,
      board: board,
      legislative_session: legislative_session,
      played_tactic: self,
    }      
  end

end
