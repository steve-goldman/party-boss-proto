require_relative '../objects/game_snapshot'

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
        puts "selecting candidate for race ##{i}"
        if @team == office_holder.team
          puts "  encumbent #{office_holder.politician} is on your team"
          office_holder.politician
        else
          puts "  candidate to run against #{office_holder.politician}"
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
      print "  (enter candidate # or 'list'): "
      input = gets.chomp
      if input == 'list'
        hand.politicians.each_index do |i|
          puts "  #{i + 1}: #{hand.politicians[i]}"
        end
      elsif input.to_i < 1 || input.to_i > hand.politicians.count
        puts "  input #{input} is out of range"
      else
        politician = hand.politicians[input.to_i - 1]
        hand.politicians.delete_at(input.to_i - 1)
        return politician
      end
    end
  end

  def confirm_candidates(office_holders, candidates)
    puts "you have selected:"
    candidates.each_index do |index|
      if office_holders[index].politician == candidates[index]
        puts "  #{candidates[index]} (encumbent)"
      else
        puts "  #{candidates[index]} versus #{office_holders[index].politician}"
      end
    end
    return confirm
  end

  def confirm
    print "(confirm? y/n): "
    return gets.chomp.downcase == 'y'
  end

end
