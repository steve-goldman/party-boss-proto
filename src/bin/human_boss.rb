require_relative '../objects/config'
require_relative '../objects/game_snapshot'
require_relative 'logger'

class HumanBoss

  def initialize(party, hand)
    @party = party
    @hand = hand
  end

  def get_candidates(game_snapshot)
    while true
      # don't spoil the data until the user confirms
      temp_politicians = @hand.politicians.clone
      # get the candidates from the user
      i = 0
      candidates = game_snapshot.board.office_holders.map do |office_holder|
        i += 1
        Logger.subheader("Selecting candidate for race ##{i}").indent
        if @party == office_holder.party
          Logger.log("Encumbent #{office_holder.politician} is in your party").unindent
          office_holder.politician
        else
          Logger.log "Candidate to run against #{office_holder.politician}"
          input_from_and_remove_from_array temp_politicians
        end
      end
      # ask user to confirm
      if confirm_candidates game_snapshot.board.office_holders, candidates
        return candidates
      end
    end
  end

  def get_bills
    while true
      # don't spoil the data until the user confirms
      temp_bills = @hand.bills.clone
      # get the bills from the user
      bills = []
      Config.get.bills_num_on_floor.times do |index|
        Logger.subheader("Selecting bill for floor matchup ##{index + 1}").indent
        bills.push input_from_and_remove_from_array(temp_bills)
      end
      # ask user to confirm
      if confirm_bills bills
        return bills
      end
    end
  end

  def get_allocation(total_dice, matchup_descriptions)
    while true
      Logger.subheader("Distribute #{total_dice} dice").indent
      allocation = matchup_descriptions.map do |matchup_description|
        input_allocation matchup_description
      end
      Logger.unindent
      if allocation.reduce(:+) > total_dice
        Logger.error("Total dice must not exceed #{total_dice}")
      elsif confirm_allocation allocation, total_dice, matchup_descriptions
        return DiceAllocation.new allocation
      end
    end
  end

  private

  def input_from_and_remove_from_array(options)
    # show the list
    options.count.times do |index|
      Logger.log "#{index + 1}: #{options[index]}"
    end
    # get the input
    while true
      Logger.prompt "(Enter #): "
      input = gets.chomp
      if !int_in_range? input, 1, options.count
        Logger.error "Input #{input} is out of range"
      else
        politician = options[input.to_i - 1]
        options.delete_at(input.to_i - 1)
        Logger.unindent
        return politician
      end
    end
  end

  def confirm_candidates(office_holders, candidates)
    Logger.subheader("You have selected:").indent
    Config.get.seats_num.times do |index|
      if office_holders[index].politician == candidates[index]
        Logger.log "#{candidates[index]} (encumbent)"
      else
        Logger.log "#{candidates[index]} versus #{office_holders[index].politician}"
      end
    end
    Logger.unindent
    confirm
  end

  def confirm_bills(bills)
    Logger.subheader("You have selected:").indent
    Config.get.bills_num_on_floor.times do |index|
      Logger.log "#{bills[index]}"
    end
    Logger.unindent
    confirm
  end

  def input_allocation(matchup_description)
    while true
      Logger.log "#{matchup_description}"
      Logger.prompt "(Enter number of dice): "
      num_dice = gets.chomp.downcase
      if !int_in_range? num_dice, 0, 999999
        Logger.error "#{num_dice} is out of range"
      else
        return num_dice.to_i
      end
    end
  end

  def confirm_allocation(allocation, total_dice, matchup_descriptions)
    Logger.subheader("You have allocated:").indent
    matchup_descriptions.each_index do |index|
      Logger.log "#{allocation[index]} for #{matchup_descriptions[index]}"
    end
    Logger.log "#{total_dice - allocation.reduce(:+)} left over"
    Logger.unindent
    return confirm
  end

  def confirm
    while true
      Logger.prompt "(Confirm? y/n): "
      choice = gets.chomp
      if choice.downcase == 'y'
        return true
      elsif choice.downcase == 'n'
        return false
      end
      Logger.error "#{choice} is not valid"
    end
  end

  def int_in_range?(input, min, max)
    return input =~ /^[0-9]+$/ && input.to_i >= min && input.to_i <= max
  end
    
end
