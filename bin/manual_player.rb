require_relative '../objects/game_snapshot'
require_relative 'logger'

class ManualPlayer

  def initialize(team, hand)
    @team = team
    @hand = hand
  end

  def get_candidates(game_snapshot)
    while true
      # don't spoil the data until the user confirms
      temp_hand = Hand.new @hand.politicians.clone
      # get the candidates from the user
      i = 0
      candidates = game_snapshot.board.office_holders.map do |office_holder|
        i += 1
        Logger.subheader("Selecting candidate for race ##{i}").indent
        if @team == office_holder.team
          Logger.log("Encumbent #{office_holder.politician} is on your team").unindent
          office_holder.politician
        else
          Logger.log "Candidate to run against #{office_holder.politician}"
          input_candidate temp_hand
        end
      end
      # ask user to confirm
      if confirm_candidates game_snapshot.board.office_holders, candidates
        # remove candidates from the player's hand
        candidates.each { |candidate| @hand.politicians.delete candidate }
        return candidates
      end
    end
  end

  private

  def input_candidate(hand)
    while true
      Logger.prompt "(Enter candidate # or 'list'): "
      input = gets.chomp
      if input == 'list'
        hand.politicians.each_index do |i|
          Logger.log "#{i + 1}: #{hand.politicians[i]}"
        end
      elsif input.to_i < 1 || input.to_i > hand.politicians.count
        Logger.log "Input #{input} is out of range"
      else
        politician = hand.politicians[input.to_i - 1]
        hand.politicians.delete_at(input.to_i - 1)
        Logger.unindent
        return politician
      end
    end
  end

  def confirm_candidates(office_holders, candidates)
    Logger.subheader("You have selected:").indent
    candidates.each_index do |index|
      if office_holders[index].politician == candidates[index]
        Logger.log "#{candidates[index]} (encumbent)"
      else
        Logger.log "#{candidates[index]} versus #{office_holders[index].politician}"
      end
    end
    Logger.unindent
    return confirm
  end

  def confirm
    Logger.prompt "(Confirm? y/n): "
    return gets.chomp.downcase == 'y'
  end

end
