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

  def can_play(board, legislative_session)
    tactic.preconditions.select do |precondition|
      !precondition.holds(precondition_args(board, legislative_session))
    end.empty?
  end

  def apply_preactions(played_tactic_index, legislative_session, game_state, boss_A, boss_B)
    if tactic.filibuster?
      apply_filibuster(game_state)
    elsif tactic.tabling_motion?
      apply_tabling_motion(legislative_session, game_state, boss_A, boss_B)
    elsif tactic.cloture?
      apply_cloture(played_tactic_index, legislative_session)
    end
  end

  def apply_actions(board, legislative_session, boss_A, boss_B, dice_roller, played_tactic_index)
    tactic.actions.each do |action|
      action.apply(action_args(board, legislative_session, boss_A, boss_B, dice_roller, played_tactic_index))
    end
  end

  def immediate?
    tactic.filibuster? || tactic.tabling_motion? || tactic.cloture?
  end

  private

  def apply_filibuster(game_state)
    if drawn_tactic.nil?
      drawn_tactics = game_state.deal_tactics(party_played_by, 1)
      if !drawn_tactics.empty?
        self.drawn_tactic = drawn_tactics[0]
      else
        self.drawn_tactic = Tactic::Pass
      end
    else
      # drawn tactic comes out of the deck
      game_state.delete_from(game_state.tactic_deck, drawn_tactic)
    end

    # drawn tactic goes into the hand
    if drawn_tactic != Tactic::Pass
      Logger.subheader "Boss '#{party_played_by}' filibustered and drew #{drawn_tactic}"
      game_state.send("hand_#{party_played_by}").tactics.push(drawn_tactic)
    else
      Logger.subheader "The '#{party_played_by}' filibustered but the tactics deck was empty"
    end
  end

  def apply_tabling_motion(legislative_session, game_state, boss_A, boss_B)
    if replacement_bill.nil?
      Logger.header("Boss #{party_played_on} choosing a replacement bill").indent
      self.replacement_bill = (party_played_on == 'A' ? boss_A : boss_B)
                              .get_bill(legislative_session.get_bills_on_floor(party_played_on))
    end

    old_bill = legislative_session.get_bill_on_floor(index, party_played_on)
    Logger.subheader "Boss '#{party_played_on}' tabled #{old_bill} for #{replacement_bill}"
    legislative_session.table_bill(index, party_played_on, replacement_bill)
  end

  def apply_cloture(played_tactic_index, legislative_session)
    Logger.subheader "Cloture played on '#{party_played_on}'s bill #{legislative_session.get_bill_on_floor(index, party_played_on)}"
    legislative_session.cloture_bill(played_tactic_index, party_played_on)
  end
  
  def precondition_args(board, legislative_session)
    {
      party_played_by: party_played_by,
      party_played_on: party_played_on,
      index: index,
      board: board,
      legislative_session: legislative_session,
    }
  end

  def action_args(board, legislative_session, boss_A, boss_B, dice_roller, played_tactic_index)
    {
      party_played_by: party_played_by,
      party_played_on: party_played_on,
      index: index,
      board: board,
      legislative_session: legislative_session,
      boss_A: boss_A,
      boss_B: boss_B,
      played_tactic: self,
      dice_roller: dice_roller,
      played_tactic_index: played_tactic_index,
    }
  end

end
