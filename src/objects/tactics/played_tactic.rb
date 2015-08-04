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

  def apply_preactions(game_snapshot, boss_A, boss_B)
    if tactic.filibuster?
      apply_filibuster(game_snapshot, boss_A, boss_B)
    end
  end

  def apply_actions(board, legislative_session, boss_A, boss_B, dice_roller)
    tactic.actions.each do |action|
      action.apply(action_args(board, legislative_session, boss_A, boss_B, dice_roller))
    end
  end

  def immediate?
    tactic.filibuster?
  end

  private

  def apply_filibuster(game_snapshot, boss_A, boss_B)
    if drawn_tactic.nil?
      drawn_tactics = game_snapshot.deal_tactics(party_played_by, 1)
      if !drawn_tactics.empty?
        self.drawn_tactic = drawn_tactics[0]
      else
        self.drawn_tactic = Tactic::Pass
      end
    else
      # drawn tactic comes out of the deck
      game_snapshot.tactic_deck.delete_if do |deck_tactic|
        deck_tactic.equals?(drawn_tactic)
      end
    end

    # drawn tactic goes into the hand
    if drawn_tactic != Tactic::Pass
      Logger.subheader "Boss '#{party_played_by}' filibustered and drew #{drawn_tactic}"
      game_snapshot.send("hand_#{party_played_by}").tactics.push(drawn_tactic)
    else
      Logger.subheader "The '#{party_played_by}' filibustered but the tactics deck was empty"
    end
  end

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
